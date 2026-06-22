// #include <ESP8266WiFi.h>
// #include <Firebase_ESP_Client.h>
// #include <DHT.h>
// #include <Arduino.h>

// // Firebase helper
// #include <addons/TokenHelper.h>
// #include <addons/RTDBHelper.h>

// unsigned long lastFirebaseUpdate = 0;
// const unsigned long FIREBASE_INTERVAL = 10000; // 10 giây
// // ==================== WIFI ====================
// #define WIFI_SSID     "Automation House"
// #define WIFI_PASSWORD "1234567890"

// // ==================== FIREBASE ====================
 #define API_KEY      "AIzaSyB3FHF87-2SDs7o3-xuggumYIhv5yMwxD8"
 #define DATABASE_URL "https://finalproject-3f736-default-rtdb.asia-southeast1.firebasedatabase.app"

#include <ESP8266WiFi.h>
#include <Firebase_ESP_Client.h>
#include <DHT.h>

#include <addons/TokenHelper.h>
#include <addons/RTDBHelper.h>

// ================= WIFI =================
#define WIFI_SSID      "PTN ICSLab"
#define WIFI_PASSWORD  "Lab705a4"

// ================= FIREBASE =================


// ================= PIN =================
#define IR_PIN         D1
#define DHT_PIN        D5
#define FAN_PIN        D6
#define BUZZER_PIN     D7
#define MQ_PIN         A0

#define DHTTYPE DHT11

DHT dht(DHT_PIN, DHTTYPE);

// Firebase
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

bool signupOK = false;

// Timer
unsigned long lastFirebaseUpdate = 0;

// Control
String controlMode = "AUTO";
bool fanControl = false;

void setup()
{
    Serial.begin(115200);

    pinMode(IR_PIN, INPUT);

    pinMode(FAN_PIN, OUTPUT);
    pinMode(BUZZER_PIN, OUTPUT);

    digitalWrite(FAN_PIN, LOW);
    digitalWrite(BUZZER_PIN, LOW);

    dht.begin();

    Serial.println();
    Serial.println("Connecting WiFi...");

    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

    while (WiFi.status() != WL_CONNECTED)
    {
        delay(500);
        Serial.print(".");
    }

    Serial.println();
    Serial.println("WiFi Connected");
    Serial.println(WiFi.localIP());

    // Firebase
    config.api_key = API_KEY;
    config.database_url = DATABASE_URL;

    if (Firebase.signUp(&config, &auth, "", ""))
    {
        Serial.println("Firebase SignUp OK");
        signupOK = true;
    }
    else
    {
        Serial.printf("Signup Error: %s\n",
                      config.signer.signupError.message.c_str());
    }

    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);

    Firebase.RTDB.setString(&fbdo, "/control/mode", "AUTO");
    Firebase.RTDB.setBool(&fbdo, "/control/fan", false);

    Serial.println("================================");
    Serial.println(" FIRE MONITORING SYSTEM ");
    Serial.println("================================");
}

void loop()
{
    // ==========================================
    // READ CONTROL FROM FIREBASE
    // ==========================================
    if (Firebase.ready() && signupOK)
    {
        if (Firebase.RTDB.getString(&fbdo, "/control/mode"))
        {
            controlMode = fbdo.stringData();
        }

        if (Firebase.RTDB.getBool(&fbdo, "/control/fan"))
        {
            fanControl = fbdo.boolData();
        }
    }

    // ==========================================
    // SENSOR READ
    // ==========================================
    int gasADC = analogRead(MQ_PIN);

    bool flameDetected =
        (digitalRead(IR_PIN) == LOW);

    float temperature =
        dht.readTemperature();

    float humidity =
        dht.readHumidity();

    // ==========================================
    // STATUS
    // ==========================================
    String gasStatus = "SAFE";
    bool fireRisk = false;

    if (flameDetected)
    {
        gasStatus = "DANGER";
        fireRisk = true;
    }
    else if (gasADC < 400)
    {
        gasStatus = "SAFE";
    }
    else if (gasADC < 700)
    {
        gasStatus = "WARNING";
    }
    else
    {
        gasStatus = "DANGER";
        fireRisk = true;
    }

    // nhiệt độ quá cao
    if (!isnan(temperature) && temperature >= 50)
    {
        gasStatus = "DANGER";
        fireRisk = true;
    }

    // ==========================================
    // FAN CONTROL
    // ==========================================
    bool fanState = false;

    if (controlMode == "AUTO")
    {
        if (gasADC >= 400 || flameDetected)
        {
            fanState = true;
        }
    }
    else
    {
        fanState = fanControl;
    }

    digitalWrite(FAN_PIN, fanState);

    // ==========================================
    // BUZZER CONTROL
    // ==========================================

    // DANGER
    if (flameDetected ||
        gasADC >= 700 ||
        (!isnan(temperature) && temperature >= 50))
    {
        digitalWrite(BUZZER_PIN, HIGH);
    }

    // WARNING
    else if (gasADC >= 400)
    {
        digitalWrite(BUZZER_PIN, HIGH);
        delay(100);

        digitalWrite(BUZZER_PIN, LOW);
        delay(900);
    }

    // SAFE
    else
    {
        digitalWrite(BUZZER_PIN, LOW);
    }

    // ==========================================
    // FIREBASE UPDATE
    // ==========================================
    if (Firebase.ready() &&
        signupOK &&
        millis() - lastFirebaseUpdate > 10000)
    {
        lastFirebaseUpdate = millis();

        Firebase.RTDB.setInt(
            &fbdo,
            "/FireMonitoring/gasADC",
            gasADC);

        Firebase.RTDB.setString(
            &fbdo,
            "/FireMonitoring/gasStatus",
            gasStatus);

        Firebase.RTDB.setBool(
            &fbdo,
            "/FireMonitoring/flameDetected",
            flameDetected);

        Firebase.RTDB.setBool(
            &fbdo,
            "/FireMonitoring/fireRisk",
            fireRisk);

        Firebase.RTDB.setBool(
            &fbdo,
            "/FireMonitoring/fanStatus",
            fanState);

        if (!isnan(temperature))
        {
            Firebase.RTDB.setFloat(
                &fbdo,
                "/FireMonitoring/temperature",
                temperature);
        }

        if (!isnan(humidity))
        {
            Firebase.RTDB.setFloat(
                &fbdo,
                "/FireMonitoring/humidity",
                humidity);
        }
    }

    // ==========================================
    // SERIAL
    // ==========================================
    Serial.println("--------------------------------");

    Serial.print("Gas ADC: ");
    Serial.println(gasADC);

    Serial.print("Gas Status: ");
    Serial.println(gasStatus);

    Serial.print("Flame: ");
    Serial.println(flameDetected ? "YES" : "NO");

    Serial.print("Temperature: ");
    Serial.print(temperature);
    Serial.println(" C");

    Serial.print("Humidity: ");
    Serial.print(humidity);
    Serial.println(" %");

    Serial.print("Mode: ");
    Serial.println(controlMode);

    Serial.print("Fan: ");
    Serial.println(fanState ? "ON" : "OFF");

    Serial.print("Fire Risk: ");
    Serial.println(fireRisk ? "YES" : "NO");

    delay(1000);
}