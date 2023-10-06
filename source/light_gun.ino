const int buttonPin = 2; // button input
const int hit = 12;       // indicate if target is hit
const int buttonOut = 13;  // indicate when button is pressed

const int threshold = 30; // light level threshold for hit
const int interval = 50; // delay between black frame and white box

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(buttonPin, INPUT);
  pinMode(hit, OUTPUT);
  pinMode(buttonOut, OUTPUT);
}

void loop() {
  int buttonState = digitalRead(buttonPin);
  if (buttonState == HIGH){
    digitalWrite(buttonOut, HIGH); //send signal to Zedboard

    delay(50); //input lag

    //calibrate dark level
    int cal = analogRead(A0); 
    Serial.print("cal: ");
    Serial.print(cal);
    
    delay(interval);

    //sample light level
    int hitscan = analogRead(A0);
    Serial.print(" hitscan: ");
    Serial.println(hitscan);

    Serial.println(cal - hitscan);
    
    //if hit
    if((cal-hitscan) >= threshold){
      digitalWrite(hit, HIGH);
      delay(150);
      digitalWrite(hit, LOW);
    }else { //if miss
      digitalWrite(hit, LOW);
      delay(150);
    }
    delay(10);
  } else {
    digitalWrite(buttonOut, LOW);
  }
}
