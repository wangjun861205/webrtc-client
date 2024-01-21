class Message {
  String token;
  String to;
  String payload;

  Message({required this.token, required this.to, required this.payload});

  Map<String, dynamic> toJson() {
    return {"token": token, "to": to, "payload": payload};
  }
}

class Payload {
  String typ;
  String payload;

  Payload({required this.typ, required this.payload});

  Map<String, dynamic> toJson() {
    return {
      "typ": typ,
      "payload": payload,
    };
  }

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(typ: json["typ"], payload: json["payload"]);
  }
}
