#include <Wire.h>
#include <FirebaseESP32.h>
#include <DHT.h>
#include <WiFi.h>
#include <ArduinoJson.h>
#include <Adafruit_GFX.h>    
#include <Adafruit_ST7735.h> 
#include "FontMaker.h"
#include <SPI.h>

//Pin for ESP32
  #define TFT_CS         5  //case select connect to pin 5
  #define TFT_RST        15 //reset connect to pin 15
  #define TFT_DC         25 //AO connect to pin 25  
  #define TFT_MOSI       23 //Data = SDA connect to pin 23
  #define TFT_SCLK       18 //Clock = SCK connect to pin 18

// For ST7735-based displays, we will use this call
Adafruit_ST7735 tft = Adafruit_ST7735(TFT_CS, TFT_DC, TFT_MOSI, TFT_SCLK, TFT_RST);

#define WIFI_SSID "Hoang"
#define WIFI_PASSWORD "01673321827"

#define FIREBASE_HOST "https://dht11-68fae-default-rtdb.firebaseio.com/"
#define FIREBASE_AUTH "bK28pFhev8u9p4bZVpcPXi9wDUnPCqDSqPXlYJyP"

#define DHTPIN 14     // Chân dữ liệu của DHT11, với NodeMCU chân D5 GPIO là 14
#define DHTTYPE DHT11 // Loại cảm biến DHT11
#define RELAY_PIN 4 // Chân GPIO kết nối đến chân điều khiển của relay
#define BTN_CAIDAT 35
#define BTN_TANG 27
#define BTN_GIAM 32

DHT dht(DHTPIN, DHTTYPE);

FirebaseData fbdo;

int doam_bomtuoi;
int doam_tatbomtuoi;
int cai_dat = 0;

void setpx(int16_t x,int16_t y,uint16_t color)
{
  tft.drawPixel(x,y,color); 
}
MakeFont myfont(&setpx);

void IRAM_ATTR CAI_DAT(){
  cai_dat = cai_dat + 1;
}
void IRAM_ATTR TANG(){
  if(cai_dat == 1){          
    doam_bomtuoi = doam_bomtuoi +1 ;
  }else if(cai_dat == 2){
    doam_tatbomtuoi = doam_tatbomtuoi +1;
  }   
}
void IRAM_ATTR GIAM(){
  if(cai_dat == 1){          
    doam_bomtuoi = doam_bomtuoi -1;
  }else if(cai_dat == 2){
    doam_tatbomtuoi = doam_tatbomtuoi -1;
  }   
}

void setup() {

  Serial.begin(19200);
  Wire.begin();
  delay(1000);
  pinMode(RELAY_PIN, OUTPUT); // Thiết lập chân GPIO là OUTPUT
  digitalWrite(RELAY_PIN, HIGH);
  pinMode(BTN_CAIDAT, INPUT_PULLDOWN);
  pinMode(BTN_TANG, INPUT_PULLDOWN);
  pinMode(BTN_GIAM, INPUT_PULLDOWN);
  attachInterrupt(digitalPinToInterrupt(BTN_CAIDAT), CAI_DAT, RISING);
  attachInterrupt(digitalPinToInterrupt(BTN_TANG), TANG, RISING);
  attachInterrupt(digitalPinToInterrupt(BTN_GIAM), GIAM, RISING);

 // Kết nối WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.println("Failed ");    
    delay(500);
  }

  dht.begin();
  
  Serial.println("");
  Serial.println("Đã kết nối WiFi!");
  Serial.println(WiFi.localIP());
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);  
  tft.initR(INITR_BLACKTAB);
  tft.fillScreen(ST7735_BLACK); //----------------------------------------------cài đặt màu nền
  hien_thi();

}

void hien_thi(){
  myfont.set_font(MakeFont_Font03);

  myfont.print(3,9,"NHIỆT ĐỘ:         °C",ST7735_RED,ST7735_BLACK);
  tft.drawRect(0,0,128,28,ST7735_WHITE);              //Hien thi khung 
  
  myfont.print(3,40,"ĐỘ ẨM KK:         %",ST7735_CYAN,ST7735_BLACK);
  tft.drawRect(0,31,128,28,ST7735_WHITE);              //Hien thi khung 

  myfont.print(3,70,"ĐỘ ẨM ĐA:          %",ST7735_CYAN,ST7735_BLACK);
  tft.drawRect(0,61,128,28,ST7735_WHITE);              //Hien thi khung 
 
  myfont.print(3,101,"BẬT BƠM:            %",ST7735_YELLOW,ST7735_BLACK);
  tft.drawRect(0,91,128,28,ST7735_WHITE);              //Hien thi khung 

  myfont.print(3,131,"TẮT BƠM:            %",ST7735_YELLOW,ST7735_BLACK);
  tft.drawRect(0,121,128,28,ST7735_WHITE);              //Hien thi khung 
}

void loop() {   
  int doam = dht.readHumidity();
  int nhietdo = dht.readTemperature();  // Đọc nhiệt độ theo độ C
  int doam_dat = map(analogRead(34),0,4095,100,0);  
  bool chedo;
  bool bom;

  Firebase.setFloat(fbdo, "Nhietdo", nhietdo);
  Firebase.setFloat(fbdo, "DoamKK", doam);
  Firebase.setFloat(fbdo, "Doamdat", doam_dat);

  Firebase.getString(fbdo,F("/Doam_bat_bom"));
  doam_bomtuoi = fbdo.stringData().toInt();
  Firebase.getString(fbdo,F("/Doam_tat_bom"));
  doam_tatbomtuoi = fbdo.stringData().toInt();
  Firebase.getString(fbdo,F("/chedo"));
  chedo = fbdo.stringData().toInt();
  Firebase.getString(fbdo,F("/bom"));
  bom = fbdo.stringData().toInt();

  tft.setCursor(75,7);                   //Hien thi nhiet do
  tft.setTextColor(ST7735_RED,ST7735_BLACK);
  tft.setTextSize(2);
  tft.print(String(nhietdo));

  tft.setCursor(81,38);                   //Hien thi do am kk
  tft.setTextColor(ST7735_CYAN,ST7735_BLACK);
  tft.setTextSize(2);
  tft.print(String(doam));
  
  tft.setCursor(76,68);                   //Hien thi do am dat
  tft.setTextColor(ST7735_CYAN,ST7735_BLACK);
  tft.setTextSize(2);
  tft.print(String(doam_dat)+" ");

  tft.setCursor(71,99);                   //Hien thi do am bat bom
  tft.setTextColor(ST7735_YELLOW,ST7735_BLACK);
  tft.setTextSize(2);
  tft.print(String(doam_bomtuoi)+" ");

  tft.setCursor(71,129);                   //Hien thi do am tat bom
  tft.setTextColor(ST7735_YELLOW,ST7735_BLACK);
  tft.setTextSize(2);
  tft.print(String(doam_tatbomtuoi)+" ");

// Điều khiển BƠM
  if(chedo == 1){
    if (doam_dat <= doam_bomtuoi) {
      digitalWrite(RELAY_PIN, LOW);
    }
    if (doam_dat >= doam_tatbomtuoi) {
      digitalWrite(RELAY_PIN, HIGH); 
    }     
  }else{
    if(bom == 1) digitalWrite(RELAY_PIN, LOW);
    else digitalWrite(RELAY_PIN, HIGH);
  }  

 if(cai_dat != 0){
  while(true){
    if(cai_dat == 1){
       tft.drawRect(0,91,128,28,ST7735_RED);          
    }else if(cai_dat == 2){
      tft.drawRect(0,121,128,28,ST7735_RED);
      tft.drawRect(0,91,128,28,ST7735_WHITE);
    }   

    tft.setCursor(71,99);                   //Hien thi do am bat bom
    tft.setTextColor(ST7735_YELLOW,ST7735_BLACK);
    tft.setTextSize(2);
    tft.print(String(doam_bomtuoi)+" ");

    tft.setCursor(71,129);                   //Hien thi do am tat bom
    tft.setTextColor(ST7735_YELLOW,ST7735_BLACK);
    tft.setTextSize(2);
    tft.print(String(doam_tatbomtuoi)+" ");

    Firebase.setFloat(fbdo, "Doam_bat_bom", doam_bomtuoi);
    Firebase.setFloat(fbdo, "Doam_tat_bom", doam_tatbomtuoi);

    if(cai_dat > 2){      
      tft.drawRect(0,91,128,28,ST7735_WHITE);
      tft.drawRect(0,121,128,28,ST7735_WHITE);
      cai_dat = 0;
      break;  
    } 
  }
 }
  
}



