// import UDP library
import hypermedia.net.*;

UDP udp;  // define the UDP object

/**
 * init
 */
void initUDP() {

  // create a new datagram connection on port 6000
  // and wait for incomming message
  udp = new UDP( this, 6000 );
  //udp.log( true );     // <-- printout the connection activity
  udp.listen( true );
}


/**
 * To perform any action on datagram reception, you need to implement this 
 * handler in your code. This method will be automatically called by the UDP 
 * object each time he receive a nonnull message.
 * By default, this method have just one argument (the received message as 
 * byte[] array), but in addition, two arguments (representing in order the 
 * sender IP address and his port) can be set like below.
 */
// void receive( byte[] data ) {       // <-- default handler
void receive( byte[] data, String ip, int port ) {  // <-- extended handler
  
  
  // get the "real" message =
  // forget the ";\n" at the end <-- !!! only for a communication with Pd !!!
  data = subset(data, 0, data.length-2);
  String message = new String( data );
  
  if (message.contains("Manifest,Left")) {
    sliderBrightness = sliderBrightness -1 < 0 ? 0 : sliderBrightness - 1;
    println("sliderBrightness: " + sliderBrightness);
    cp5.getController("sliderBrightness").setValue(sliderBrightness);
  } else if (message.contains("Manifest,Right")) {
    sliderBrightness = sliderBrightness +1 > 255 ? 255 : sliderBrightness + 1;
    println("sliderBrightness: " + sliderBrightness);
    cp5.getController("sliderBrightness").setValue(sliderBrightness);
  } else if (message.contains("Manifest,Av1")) {
    prevDemo(1);
  } else if (message.contains("Manifest,Av2")) {
    nextDemo(1);
  } 
    
  
  // print the result
  //println( "receive: \""+message+"\" from "+ip+" on port "+port );
}
