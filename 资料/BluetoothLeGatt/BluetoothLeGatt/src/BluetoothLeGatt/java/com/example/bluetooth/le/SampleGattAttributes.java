/*
 * Copyright (C) 2013 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.example.bluetooth.le;

import java.util.HashMap;

/**
 * This class includes a small subset of standard GATT attributes for demonstration purposes.
 */
public class SampleGattAttributes {
    private static HashMap<String, String> attributes = new HashMap();

    public static String GENERIC_ACCESS_SERVICE            = "00001800-0000-1000-8000-00805f9b34fb";
    public static String GENERIC_ACCESS_DEVICE_NAME        = "00002a00-0000-1000-8000-00805f9b34fb";
    public static String GENERIC_ACCESS_APPEARANCE         = "00002a01-0000-1000-8000-00805f9b34fb";
    public static String GENERIC_ATTRIBUTE_SERVICE         = "00001801-0000-1000-8000-00805f9b34fb";
    public static String GENERIC_ATTRIBUTE_SERVICE_CHANGED = "00002a05-0000-1000-8000-00805f9b34fb";
    public static String DEVICES_INFO_SERVICE              = "0000180a-0000-1000-8000-00805f9b34fb";
    public static String DEVICES_INFO_SYSTEM_ID            = "00002a23-0000-1000-8000-00805f9b34fb";
    public static String BATTERY_SERVICE                   = "0000180f-0000-1000-8000-00805f9b34fb";
    public static String BATTERY_LEVEL                     = "00002a19-0000-1000-8000-00805f9b34fb";
    public static String DESCRIPTION                       = "00002901-0000-1000-8000-00805f9b34fb";
    public static String CLIENT_CONFIGURATION              = "00002902-0000-1000-8000-00805f9b34fb";
    public static String CURRENT_TIME_SERVICE              = "00001805-0000-1000-8000-00805f9b34fb";
    public static String CURRENT_TIME                      = "00002a2b-0000-1000-8000-00805f9b34fb";
    public static String RUNNING_SPEED_AND_CADENCE_SERVICE = "00001814-0000-1000-8000-00805f9b34fb";
    public static String RUNNING_SPEED_AND_CADENCE         = "0000ffa6-0000-1000-8000-00805f9b34fb";
    public static String OFFLINE_DATA_SERVICE              = "0000ffc0-0000-1000-8000-00805f9b34fb";
    public static String OFFLINE_DATA_CLEAR                = "0000ffc1-0000-1000-8000-00805f9b34fb";
    public static String OFFLINE_DATA                      = "0000ffc2-0000-1000-8000-00805f9b34fb";
    public static String OFFLINE_DATA_TRANSPARENT          = "0000ffc3-0000-1000-8000-00805f9b34fb";
    public static String CUSTOMER_SERVICE                  = "0000ffd0-0000-1000-8000-00805f9b34fb";
    public static String CUSTOMER_PARAMETER                = "0000ffd1-0000-1000-8000-00805f9b34fb";
    public static String CUSTOMER_CAMERA                   = "0000ffd2-0000-1000-8000-00805f9b34fb";
    public static String CUSTOMER_COMMING_CALL             = "0000ffd3-0000-1000-8000-00805f9b34fb";

    static {
        attributes.put(GENERIC_ACCESS_SERVICE, "GENERIC ACCESS SERVICE");
        attributes.put(GENERIC_ATTRIBUTE_SERVICE, "GENERIC ATTRIBUTE SERVICE");
        attributes.put(DEVICES_INFO_SERVICE, "DEVICES INFO SERVICE");
        attributes.put(BATTERY_SERVICE, "BATTERY SERVICE");
        attributes.put(CURRENT_TIME_SERVICE, "CURRENT TIME SERVICE");
        attributes.put(RUNNING_SPEED_AND_CADENCE_SERVICE, "RUNNING SPEED AND CADENCE SERVICE");
        attributes.put(OFFLINE_DATA_SERVICE, "OFFLINE DATA SERVICE SERVICE");
        attributes.put(CUSTOMER_SERVICE, "CUSTOMER SERVICE");

        attributes.put(GENERIC_ACCESS_DEVICE_NAME, "GENERIC ACCESS DEVICE NAME");
        attributes.put(GENERIC_ACCESS_APPEARANCE, "GENERIC ACCESS APPEARANCE");
        attributes.put(GENERIC_ATTRIBUTE_SERVICE_CHANGED, "GENERIC ATTRIBUTE SERVICE CHANGED");
        attributes.put(DEVICES_INFO_SYSTEM_ID, "DEVICES INFO SYSTEM ID");
        attributes.put(BATTERY_LEVEL, "BATTERY LEVEL");
        attributes.put(DESCRIPTION, "DESCRIPTION");
        attributes.put(CLIENT_CONFIGURATION, "CLIENT CONFIGURATION");
        attributes.put(CURRENT_TIME, "CURRENT TIME");
        attributes.put(RUNNING_SPEED_AND_CADENCE, "RUNNING SPEED AND CADENCE");
        attributes.put(OFFLINE_DATA_CLEAR, "OFFLINE DATA CLEAR");
        attributes.put(OFFLINE_DATA, "OFFLINE DATA");
        attributes.put(OFFLINE_DATA_TRANSPARENT, "OFFLINE DATA TRANSPARENT");
        attributes.put(CUSTOMER_PARAMETER, "CUSTOMER PARAMETER");
        attributes.put(CUSTOMER_CAMERA, "CUSTOMER CAMERA");
        attributes.put(CUSTOMER_COMMING_CALL, "CUSTOMER COMMING CALL");
    }

    public static String lookup(String uuid, String defaultName) {
        String name = attributes.get(uuid);
        return name == null ? defaultName : name;
    }
}
