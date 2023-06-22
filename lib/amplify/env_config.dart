class EnvConfig {
  static String? restUrl;

  static String? poolId1;
  static String? region;
  static String? poolId2;
  static String? appClientId;

  static void configureEnv(String env) {
    if (env == "prod") {
      restUrl =
          "https://pgrgyn5pd4.execute-api.us-east-1.amazonaws.com/prod/api";
      poolId1 = 'us-east-1:d8dd636f-6e06-4c13-9b24-62b05f621388';
      region = 'us-east-1';
      poolId2 = 'us-east-1_SDoquCrxP';
      appClientId = 'pb9h0lh1oomkd7uvv7g4916gg';
    } else if (env == "staging") {
      restUrl =
          "https://feziwb4p74.execute-api.us-east-2.amazonaws.com/prod/api";
      poolId1 = 'us-east-1:31d9b307-a4e7-4e1f-9d0b-c3fc879212c2';
      region = 'us-east-1';
      poolId2 = 'us-east-1_wdcuCog22';
      appClientId = '23ttn32trkga73r5i2pihv2kfh';
    } else {
      restUrl =
          "https://feziwb4p74.execute-api.us-east-2.amazonaws.com/prod/api";
      poolId1 = 'us-east-1:31d9b307-a4e7-4e1f-9d0b-c3fc879212c2';
      region = 'us-east-1';
      poolId2 = 'us-east-1_wdcuCog22';
      appClientId = '23ttn32trkga73r5i2pihv2kfh';
    }
  }
}
