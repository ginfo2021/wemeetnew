class SongModel {

  final int id;
  final String artist;
  final String title;
  final String url;
  final String artwork;
  // final UserModel uploader;

  SongModel({
    this.id,
    this.artist,
    this.title,
    this.url,
    this.artwork
  });

  factory SongModel.fromMap(Map map) {
    return SongModel(
      id: map["id"],
      artist: map["artist"] ?? "Unknown artist",
      title: map["title"] ?? "Unknown title",
      url: map["songUrl"] ?? "http://song.mp3",
      artwork: map["artworkURL"] ?? map["artworkUrl"] ?? "https://www.streamplay.media/themes/streamplay/assets/images/artwork.cover.jpg"
    );
  }

  @override
  bool operator ==(covariant SongModel other)  => id == other?.id;

}

/**
 {
                "id": 13,
                "artist": "Nuks",
                "title": "test song",
                "songUrl": "https://wemeetstorage.s3.eu-west-1.amazonaws.com/music/MUSIC_1_2d66b85b-003c-42c5-9b7d-66df959b7171",
                "artworkURL": "https://wemeetstorage.s3.eu-west-1.amazonaws.com/images/ARTWORK_1_590f7270-e903-430c-988e-240e4582f022",
                "uploadedBy": {
                    "id": 1,
                    "firstName": "string",
                    "lastName": "string",
                    "profileImage": null,
                    "email": "string@string.com",
                    "emailVerified": true,
                    "phone": "string",
                    "phoneVerified": false,
                    "gender": "MALE",
                    "dateOfBirth": 1599125526000,
                    "active": true,
                    "suspended": false,
                    "type": "FREE",
                    "lastSeen": 1611677155000,
                    "dateCreated": 1599125557000
                }
            },
 */