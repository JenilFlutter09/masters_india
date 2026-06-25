package com.app.mastersindia

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.snbc.sdk.LabelPrinter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MainActivity : FlutterActivity() {
    companion object {
        private var printerSdkLoaded = false

        private fun ensurePrinterSdkLoaded() {
            if (printerSdkLoaded) return
            System.loadLibrary("ConfigFileINI")
            System.loadLibrary("SimpleLogModule")
            System.loadLibrary("LabelPrinterSDK")
            printerSdkLoaded = true
        }
    }

    private val channelName = "label_printer"
    private val mainHandler = Handler(Looper.getMainLooper())
    private var printer: LabelPrinter? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        try {
            ensurePrinterSdkLoaded()
            printer = LabelPrinter()
        } catch (error: Throwable) {
            Log.e("LabelPrinterSDK", "Failed to initialize printer SDK", error)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "connectPrinter" -> connectPrinter(call, result)
                "disconnectPrinter" -> disconnectPrinter(result)
                "getPrinterStatus" -> getPrinterStatus(result)
                "printStructuredLabel" -> printStructuredLabel(call, result)
                else -> result.notImplemented()
            }
        }
    }

    private fun connectPrinter(call: MethodCall, result: MethodChannel.Result) {
        val mac = call.argument<String>("mac").orEmpty()
        if (mac.isBlank()) {
            result.error("INVALID_MAC", "Printer MAC address is required.", null)
            return
        }

        Thread {
            try {
                ensurePrinterSdkLoaded()
                if (printer == null) {
                    printer = LabelPrinter()
                }
                val labelPrinter = printer
                    ?: throw IllegalStateException("Printer SDK unavailable.")

                val discovered = labelPrinter.DiscoverPrinter(7, 10000) ?: emptyArray()
                if (!discovered.any { it.contains(mac, ignoreCase = true) }) {
                    postError(
                        result,
                        "MAC_NOT_FOUND",
                        "Printer with MAC $mac was not found nearby or paired.",
                    )
                    return@Thread
                }

                Thread.sleep(600)
                var status = labelPrinter.ConnectPrinter(7, mac, 2)
                if (status != 0) {
                    Thread.sleep(500)
                    status = labelPrinter.ConnectPrinter(7, mac, 2)
                }

                mainHandler.post {
                    if (status == 0) {
                        result.success("Connected to printer: $mac")
                    } else {
                        result.error(
                            "CONNECTION_ERROR",
                            "Failed to connect to printer. Status code: $status",
                            null,
                        )
                    }
                }
            } catch (error: Throwable) {
                postError(
                    result,
                    "CONNECTION_EXCEPTION",
                    error.message ?: "Unknown printer connection error.",
                )
            }
        }.start()
    }

    private fun disconnectPrinter(result: MethodChannel.Result) {
        Thread {
            try {
                ensurePrinterSdkLoaded()
                val labelPrinter = printer
                if (labelPrinter == null) {
                    mainHandler.post { result.success("Printer already disconnected") }
                    return@Thread
                }

                val status = labelPrinter.Disconnect()
                printer = null
                mainHandler.post { result.success("Disconnected (status=$status)") }
            } catch (error: Exception) {
                postError(
                    result,
                    "DISCONNECT_ERROR",
                    error.message ?: "Unable to disconnect printer.",
                )
            }
        }.start()
    }

    private fun getPrinterStatus(result: MethodChannel.Result) {
        Thread {
            try {
                val labelPrinter = printer
                if (labelPrinter == null) {
                    mainHandler.post {
                        result.success(
                            mapOf(
                                "connected" to false,
                                "message" to "Printer SDK is not initialized.",
                            ),
                        )
                    }
                    return@Thread
                }

                val status = labelPrinter.GetStatus()
                val errorCode = labelPrinter.errorNo

                if (errorCode == 3 || status == null) {
                    mainHandler.post {
                        result.success(
                            mapOf(
                                "connected" to false,
                                "message" to "Printer is disconnected or unreachable.",
                            ),
                        )
                    }
                    return@Thread
                }

                mainHandler.post {
                    result.success(
                        mapOf(
                            "connected" to true,
                            "is_ready_to_print" to status.is_ready_to_print,
                            "is_paused" to status.is_paused,
                            "is_paper_out" to status.is_paper_out,
                            "is_head_opened" to status.is_head_opened,
                            "is_ribbon_out" to status.is_ribbon_out,
                            "is_cutter_error" to status.is_cutter_error,
                            "is_printer_busy" to status.is_printer_busy,
                        ),
                    )
                }
            } catch (error: Throwable) {
                mainHandler.post {
                    result.success(
                        mapOf(
                            "connected" to false,
                            "message" to (error.message ?: "Unknown printer status error."),
                        ),
                    )
                }
            }
        }.start()
    }

    private fun printStructuredLabel(call: MethodCall, result: MethodChannel.Result) {
        val title = call.argument<String>("title").orEmpty()
        val lines = call.argument<List<String>>("lines") ?: emptyList()
        val barcode = call.argument<String>("barcodeValue").orEmpty()
        val copies = call.argument<Int>("copies") ?: 1

        Thread {
            try {
                ensurePrinterSdkLoaded()
                val labelPrinter = printer
                    ?: throw IllegalStateException("Printer is not connected.")

                val sizeStatus = labelPrinter.SetLabelSize(700, 450)
                if (sizeStatus != 0) {
                    postError(
                        result,
                        "SET_LABEL_ERROR",
                        "Failed to set label size. Status code: $sizeStatus",
                    )
                    return@Thread
                }

                labelPrinter.SetPrintDensity(15)

                val left = 18
                val contentWidth = 700 - (left * 2)
                var y = 24

                val company = "MastersIndia"
                labelPrinter.PrintText(left, y, "0", company, 0, 30, 30, 1)
                y += 40

                val titleFont = fitFontSizeForWidth(title, contentWidth, 34, 22)
                labelPrinter.PrintText(left, y, "0", title, 0, titleFont, titleFont, 1)
                y += 48

                val timestamp = SimpleDateFormat(
                    "dd-MM-yyyy HH:mm",
                    Locale.getDefault(),
                ).format(Date())
                labelPrinter.PrintText(left, y, "0", timestamp, 0, 18, 18, 0)
                y += 32

                val lineFont = 22
                val lineHeight = 32
                val maxBodyY = if (barcode.isBlank()) 390 else 260
                for (line in lines) {
                    if (y > maxBodyY) break
                    for (wrapped in wrapText(line, 34)) {
                        if (y > maxBodyY) break
                        labelPrinter.PrintText(left, y, "0", wrapped, 0, lineFont, lineFont, 0)
                        y += lineHeight
                    }
                }

                if (barcode.isNotBlank()) {
                    val barcodeY = 290
                    val barcodeStatus = labelPrinter.PrintBarcode1D(
                        40,
                        barcodeY,
                        1,
                        0,
                        barcode,
                        70,
                        1,
                        3,
                        3,
                    )
                    if (barcodeStatus != 0) {
                        postError(
                            result,
                            "BARCODE_ERROR",
                            "Failed to print barcode. Status code: $barcodeStatus",
                        )
                        return@Thread
                    }
                    labelPrinter.PrintText(40, 372, "0", barcode, 0, 18, 18, 0)
                }

                val printStatus = labelPrinter.PrintLabel(copies.coerceAtLeast(1), 1)
                mainHandler.post {
                    if (printStatus == 0) {
                        result.success("Label printed successfully")
                    } else {
                        result.error(
                            "PRINT_FAILED",
                            "PrintLabel returned status code: $printStatus",
                            null,
                        )
                    }
                }
            } catch (error: Throwable) {
                postError(
                    result,
                    "PRINT_EXCEPTION",
                    error.message ?: "Unknown printer error.",
                )
            }
        }.start()
    }

    private fun fitFontSizeForWidth(
        text: String,
        maxWidth: Int,
        preferredFont: Int,
        minFont: Int,
    ): Int {
        val cleanText = text.trim()
        if (cleanText.isEmpty()) return preferredFont
        val estimatedFit = (maxWidth * 2.2 / cleanText.length).toInt()
        return estimatedFit.coerceIn(minFont, preferredFont)
    }

    private fun wrapText(text: String, maxChars: Int): List<String> {
        val cleanText = text.trim()
        if (cleanText.isEmpty()) return emptyList()

        val words = cleanText.split(Regex("\\s+"))
        val lines = mutableListOf<String>()
        var current = StringBuilder()

        for (word in words) {
            val next = if (current.isEmpty()) word else "${current} $word"
            if (next.length <= maxChars) {
                current = StringBuilder(next)
            } else {
                if (current.isNotEmpty()) {
                    lines.add(current.toString())
                }
                current = StringBuilder(word)
            }
        }

        if (current.isNotEmpty()) {
            lines.add(current.toString())
        }

        return lines
    }

    private fun postError(
        result: MethodChannel.Result,
        code: String,
        message: String,
    ) {
        mainHandler.post { result.error(code, message, null) }
    }
}
