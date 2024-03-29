package com.lorenzofelletti.simpleblescanner.blescanner

import android.annotation.SuppressLint
import android.bluetooth.BluetoothManager
import android.util.Log
import com.lorenzofelletti.simpleblescanner.BuildConfig.DEBUG
import com.lorenzofelletti.simpleblescanner.blescanner.model.BleScanCallback
import kotlin.math.pow

class BleScanRunner(private val btManager: BluetoothManager) {
    private lateinit var bleScanManager: BleScanManager

    private lateinit var foundDevices: MutableList<List<String>>

    @SuppressLint("MissingPermission")
    fun searchDevices() {

        if (DEBUG) Log.e(TAG, "Running Scan")

        foundDevices = emptyList<List<String>>().toMutableList()

        bleScanManager = BleScanManager(btManager, 5000, scanCallback = BleScanCallback({ deviceFound ->
            val macAdress = deviceFound!!.device.address.toString()
            val rssi = deviceFound.rssi

            // verificar e documentar essa função
            val distance = calculateDistanceLDPLM(rssi)

            val device:MutableList<String> = mutableListOf(macAdress, rssi.toString(), String.format("%.3f", distance))

            var hasDevice = false
            foundDevices.forEach{ it ->
                if (it[0].equals(macAdress)) {
                    true.also { hasDevice = true }
                }

            }
            if (DEBUG && !hasDevice) Log.e(TAG, "Device: $device $rssi $distance")

            if (!hasDevice) foundDevices += device

        }))

        bleScanManager.afterScanActions.add {
            if (DEBUG) Log.e(TAG, "Devices: $foundDevices")
        }

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