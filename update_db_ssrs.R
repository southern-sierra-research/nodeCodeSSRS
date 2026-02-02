function (d, outpath, myproject, fix = FALSE) 
{
  if ("CumulativeSolarCurrent" %in% colnames(df)) {
    df <- df %>% rename(radio_id = "RadioId", node_id = "NodeId", 
                        node_rssi = "NodeRSSI", battery = "Battery", celsius = "Celsius", 
                        recorded_at = "RecordedAt", firmware = "Firmware", 
                        solar_volts = "SolarVolts", solar_current = "SolarCurrent", 
                        cumulative_solar_current = "CumulativeSolarCurrent", 
                        latitude = "Latitude", longitude = "Longitude", 
                        up_time = "UpTime", charge_ma = "AverageChargerCurrentMa", 
                        energy_used_mah = "EnergyUsed", sd_free = "SdFree", 
                        sub_ghz_det = "Detections", errors = "Errors")
  }
  myfiles <- list.files(file.path(outpath, myproject), recursive = TRUE, 
                        full.names = TRUE)
  files_loc <- basename(myfiles)
  allnode <- DBI::dbReadTable(d, "data_file")
  if (fix) {
    res <- DBI::dbGetQuery(d, "select distinct path from gps")
    res2 <- DBI::dbGetQuery(d, "select distinct path from raw")
    res1 <- DBI::dbGetQuery(d, "select distinct path from node_health")
    filesdone <- c(res$path, res1$path, res2$path)
  }
  else {
    filesdone <- allnode$path
  }
  files_import <- myfiles[which(!files_loc %in% filesdone)]
  files_import <- files_import[unname(sapply(files_import, 
                                             function(x) get_file_info(x)[[1]])) %in% c("gps", "node_health", 
                                                                                        "raw", "blu")]
  write.csv(files_import, file.path(outpath, "files.csv"))
  failed2 <- lapply(files_import, get_files_import, conn = d, 
                    outpath = outpath)
}
