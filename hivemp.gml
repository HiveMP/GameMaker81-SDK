#define check_and_report_errors
// argument0 - application name
// argument1 - application version
// argument2 - public API key
// returns true if an error was reported, false otherwise

if (error_occurred) {
    error_occurred = false;
    
    show_debug_message("RAW ERROR: " + error_last);
    
    // Report the error to the online system.
    var request, st, contents, map, environmentMap, stackList, encodedJson;
    
    stackList = jso_new_list();
    
    environmentMap = jso_new_map();
    jso_map_add_string(environmentMap,  "operatingSystemName", "");
    jso_map_add_boolean(environmentMap, "operatingSystemNameIsPresent", false);
    jso_map_add_string(environmentMap,  "operatingSystemVersion", "");
    jso_map_add_boolean(environmentMap, "operatingSystemVersionIsPresent", false);
    jso_map_add_string(environmentMap,  "cpuArchitectureName", "");
    jso_map_add_boolean(environmentMap, "cpuArchitectureNameIsPresent", false);
    jso_map_add_string(environmentMap,  "gpuDeviceName", "");
    jso_map_add_boolean(environmentMap, "gpuDeviceNameIsPresent", false);
    
    userdata = jso_new_map();
    
    map = jso_new_map();
    jso_map_add_string(map, "applicationName", argument0);
    jso_map_add_string(map, "applicationVersion", argument1); // TODO Set this to a real version number!
    jso_map_add_string(map, "uniquenessHash", "");
    jso_map_add_string(map, "message", error_last);
    jso_map_add_sublist(map, "stackTrace", stackList);
    jso_map_add_submap(map, "environmentData", environmentMap);
    jso_map_add_submap(map, "userdata", userdata);
    
    encodedJson = jso_encode_map(map);
    
    jso_cleanup_map(map);
    
    show_debug_message("ENCODED: " + encodedJson);
    
    // TODO: Make this asynchronous.
    
    show_debug_message("STARTING HTTP REQUEST");
    request = httprequest_create();
    httprequest_set_request_header(request, "api_key", argument2, true);
    httprequest_set_request_header(request, "Content-Length", "0", false);
    httprequest_connect(request, "http://error-api.hivemp.com/v1/error?error=" + httprequest_urlencode(encodedJson, false), true);
    while (true) {
        httprequest_update(request);
        st = httprequest_get_state(request);
        if (st == 4 || st == 5) {
            break;
        }
        sleep(10);
    }
    show_debug_message("HTTP REQUEST IS IN STATE " + string(st));
    show_debug_message("HTTP STATUS CODE " + string(httprequest_get_status_code(request)));
    show_debug_message("HTTP RESPONSE HEADER COUNT " + string(httprequest_get_response_header_count(request)));
    if (st == 5) {
        // failed to report error
        show_debug_message("BODY: " + httprequest_get_message_body(request));
    } else if (st == 4) {
        // reported
        contents = httprequest_get_message_body(request);
        show_debug_message("BODY: " + contents)
    }
    show_debug_message("DESTROYING REQUEST");
    httprequest_destroy(request);
    
    return true;
}

return false;

