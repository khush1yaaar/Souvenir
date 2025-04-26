class JournalContent {
  final String type; // 'image', 'video', 'audio', or 'text'
  final String data; // file path or text content
  final String? id; // unique identifier for each content
  
  JournalContent({
    required this.type, 
    required this.data,
    this.id,
  });
}