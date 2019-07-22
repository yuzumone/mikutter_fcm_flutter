class MikutterMessage {
  String title;
  String body;
  String url;

  MikutterMessage({
    this.title,
    this.body,
    this.url,
  });

  MikutterMessage.fromMap(Map<String, dynamic> map): this(
    title: map['title'],
    body: map['body'],
    url: map['url'],
  );

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      title: title,
      body: body,
      url: url,
    };
  }
}
