package com.ghosten.logger

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.IBinder
import android.util.Log
import java.io.*
import java.text.SimpleDateFormat
import java.util.*
import kotlin.system.exitProcess

class LogcatService : Service(), Thread.UncaughtExceptionHandler {
    private var logcatProcess: Process? = null
    private var reader: BufferedReader? = null
    private var fileWriter: FileWriter? = null
    private val fileDateFormat: SimpleDateFormat = SimpleDateFormat(SIMPLE_DATE_FORMAT, Locale.US)
    private val binder = LocalBinder()
    private var loaded = false
    private var cachedLogFile: File? = null

    override fun onCreate() {
        super.onCreate()
        loaded = true
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        deleteOldLogFiles()
        startLogcatCapture()
        Thread.setDefaultUncaughtExceptionHandler(this)
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        cleanup()
    }

    override fun onBind(intent: Intent?): IBinder {
        return binder
    }

    override fun uncaughtException(t: Thread, e: Throwable) {
        Log.e(TAG, "Crash caught! Thread: " + t.name, e)

        readLog()
        readLog()

        android.os.Process.killProcess(android.os.Process.myPid())
        exitProcess(1)
    }

    inner class LocalBinder : Binder() {
        fun getService(): LogcatService? = if (loaded) this@LogcatService else null
    }

    private fun startLogcatCapture() {
        Thread {
            readLog()
        }.start()
    }

    private fun readLog() {

        try {
            val pid = android.os.Process.myPid()
            val pb = ProcessBuilder("logcat", "--pid=$pid", "-v", "threadtime")
            pb.redirectErrorStream(true)
            logcatProcess = pb.start()

            reader = BufferedReader(InputStreamReader(logcatProcess!!.inputStream))
            var line: String?
            while ((reader!!.readLine().also { line = it }) != null) {
                writeToFile(getLogFile(), line)
            }
        } catch (e: IOException) {
//            e.printStackTrace()
        } finally {
            cleanup()
        }
    }

    private fun getLogFile(): File {
        if (cachedLogFile != null && cachedLogFile!!.length() < LOG_FILE_MAX_SIZE) {
            return cachedLogFile!!
        } else {
            var index = 0
            val today: String? = fileDateFormat.format(Date())
            while (true) {
                val file = File(cacheDir, "logs/${today}-${index.toString().padStart(2, '0')}.log")
                if (!file.parentFile!!.exists()) {
                    file.parentFile!!.mkdirs()
                }
                if (!file.exists()) {
                    cachedLogFile = file
                    return file
                } else if (file.length() < LOG_FILE_MAX_SIZE) {
                    cachedLogFile = file
                    return file
                }
                index++
            }
        }
    }

    private fun writeToFile(file: File, logLine: String?) {
        try {
            fileWriter = FileWriter(file, true)
            fileWriter!!.write(logLine + "\n")
            fileWriter!!.flush()
            fileWriter!!.close()
        } catch (e: IOException) {
//            e.printStackTrace()
        }
    }

    private fun cleanup() {
        try {
            if (reader != null) reader!!.close()
        } catch (_: IOException) {
        }
        if (logcatProcess != null) {
            logcatProcess!!.destroy()
        }
    }

    // todo: 改为读取日期删除
    private fun deleteOldLogFiles() {
        var dir = File(cacheDir.path.plus("/logs"))
        val logList = dir.listFiles()?.filter { it.extension == "log" }?.map { it.name }?.sortedByDescending { it }
        if (logList == null) return
        var index = LOG_FILE_MAX_COUNT - 1
        while (index < logList.size) {
            val filename = logList[index]
            var file = File(dir.path.plus("/$filename"))
            if (file.exists()) file.delete()
            index++
        }
    }

    public fun queryLogPage(limit: Int, cursor: Long?, filename: String?): HashMap<String, Any> {
        var dir = File(cacheDir.path.plus("/logs"))
        val logList = dir.listFiles()?.filter { it.extension == "log" }?.map { it.name }?.sortedByDescending { it }

        if (logList == null) {
            return HashMap<String, Any>().apply {
                this["data"] = listOf<String>()
                this["cursor"] = 0
                this["isEnd"] = true
            }
        }

        var index = if (filename != null) {
            logList.indexOf(filename)
        } else 0
        if (index < 0) index = 0
        var fn = logList[index]
        var c = cursor
        var isEnd = false
        var isFirstFile = true

        var lines = mutableListOf<String>()
        while (index < logList.size && lines.size < limit) {
            fn = logList[index]
            var data = File(dir.path.plus("/$fn")).readLinesReversed(limit, if (isFirstFile) c else null)
            lines.addAll(data.data)
            c = data.cursor
            isEnd = data.isEnd
            index++
            isFirstFile = false
        }

        if (index < logList.size && isEnd) isEnd = false

        return HashMap<String, Any>().apply {
            this["data"] = lines
            this["cursor"] = c ?: 0
            this["isEnd"] = isEnd
            if (fn != null) this["filename"] = fn
        }
    }

    companion object {
        const val LOG_FILE_MAX_SIZE = 1L.shl(20)
        const val LOG_FILE_MAX_COUNT = 100
        const val TAG = "Logger"
        const val SIMPLE_DATE_FORMAT = "yyyy-MM-dd"
    }
}

fun File.readLinesReversed(limit: Int, cursor: Long?): ReadFileLines {
    if (!exists() || length() == 0L) return ReadFileLines(listOf(), 0, true)

    RandomAccessFile(this@readLinesReversed, "r").use { raf ->
        val fileLength = raf.length()
        var pointer = cursor ?: (fileLength - 1)
        var lineEnd = pointer + 1

        val lines = mutableListOf<String>()

        while (pointer >= 0) {
            raf.seek(pointer)
            val b = raf.readByte()

            if (b == '\n'.code.toByte()) {
                val lineBytes = ByteArray((lineEnd - pointer - 1).toInt())
                raf.seek(pointer + 1)
                raf.readFully(lineBytes)
                if (lineBytes.isNotEmpty()) lines.add(String(lineBytes, Charsets.UTF_8))

                lineEnd = pointer
            }

            pointer--
            if (lines.size >= limit) {
                break
            }
        }

        if (lineEnd > 0 && lines.size < limit) {
            val firstLineBytes = ByteArray(lineEnd.toInt())
            raf.seek(0)
            raf.readFully(firstLineBytes)
            if (firstLineBytes.isNotEmpty()) lines.add(String(firstLineBytes, Charsets.UTF_8))
        }

        return ReadFileLines(lines, pointer, pointer <= 0)
    }
}

data class ReadFileLines(var data: List<String>, var cursor: Long, var isEnd: Boolean)
