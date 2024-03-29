package com.example.medir_distancia_bluetooth.blescanner

import android.annotation.SuppressLint
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Intent
import android.util.Log
import com.example.medir_distancia_bluetooth.BuildConfig.DEBUG
import com.example.medir_distancia_bluetooth.blescanner.manager.BleScanManager
import com.lorenzofelletti.simpleblescanner.blescanner.model.BleScanCallback
import kotlin.math.pow

class BleScanRunner(private val btManager: BluetoothManager, private val periodTime: Long = 0, private val applicationContext:Context) {

    private lateinit var bleScanManager: BleScanManager
    private lateinit var foundDevices: MutableList<List<String>>

    @SuppressLint("MissingPermission")
    fun init(): BleScanManager {

        foundDevices = emptyList<List<String>>().toMutableList()

        bleScanManager = BleScanManager(btManager, periodTime, scanCallback = BleScanCallback({ deviceFound ->
            if (deviceFound?.device?.address.isNullOrBlank()) return@BleScanCallback
            val macAdress = deviceFound!!.device.address!!
            val name:String = (if (deviceFound.device.name != null) deviceFound.device.name else '-').toString()
            val rssi = deviceFound.rssi

            // verificar e documentar essa função
            val distance = calculateDistanceLDPLM(rssi)

            val device:MutableList<String> = mutableListOf(macAdress, name, rssi.toString(), String.format("%.3f", distance))

            var hasDevice = false
            foundDevices.forEach{
                if (it[0].equals(macAdress)) {
                    true.also { hasDevice = true }
                }

            }

            if (DEBUG) Log.e(TAG, "Device: $device $macAdress $rssi $distance")


            if (!hasDevice) {
                foundDevices += device
                val intent = Intent("com.exemple.medir_distancia_bluetooth")
                intent.putExtra("device",ArrayList(foundDevices.map { ArrayList(it) }))
                applicationContext.sendBroadcast(intent)
            }

        }))

        return bleScanManager

    }

    fun stop() {
        bleScanManager.scanBleDevices()
    }

    fun calculateDistanceLDPLM(RSSI: Int): Double {
        val RSSI0 = -66
        val n = 2.0
        return 10.0.pow((RSSI0 - RSSI) / (10 * n))
    }

    companion object {
        private val TAG = BleScanRunner::class.java.simpleName
    }
}