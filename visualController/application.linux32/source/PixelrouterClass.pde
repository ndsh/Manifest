class Pixelrouter {
  // the pixelrouter only sends out signals via artnet
  String ip;
  boolean online = true; // später überprüfen ob wirklich online
  ArtNetClient artnet;

  Pixelrouter() {
  }

  Pixelrouter(String _ip) {
    ip = _ip;
    artnet = new ArtNetClient(null);
    artnet.start();
  }
  
  String getIP() {
    return ip;
  }

  void isOnline() {
    // try-catch block zum testen ob ein pixelrouter online ist
  }

  void send(int port, byte[] data) {
    //println("sending data to router: " + ip + " / " + port + " / " + data);
    //for(int i = 0; i<360; i++) print(data[i] + ", ");
    artnet.unicastDmx(ip, 0, port, data);
  }
}
