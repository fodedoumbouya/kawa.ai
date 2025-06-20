
// part 'projectPlan.mapper.dart';

// {
//   "projectPlan": {
//     "user": {
//             "frontEnd": {
//                 "screen": [
//                     "Home",
//                     "Search",
//                     "Library",
//                     "Playlist",
//                     "Album",
//                     "Artist",
//                     "NowPlaying",
//                     "Login",
//                     "Signup",
//                     "Settings"
//                 ]
//             },
//             "backEnd": {
//                 "api": [
//                     "GET /songs",
//                     "GET /albums",
//                     "GET /artists",
//                     "GET /playlists",
//                     "POST /playlists",
//                     "PUT /playlists/{id}",
//                     "DELETE /playlists/{id}",
//                     "GET /search",
//                     "POST /auth/login",
//                     "POST /auth/signup"
//                 ]
//             }
//         },
//   "questions": [
//     "What is the purpose of the project?",
//     "What features should the project have?",
//   ]

//   }
// }

// @MappableClass()
// class ProjectPlan with ProjectPlanMappable {
//   final User user;
//   final List<String> questions;
//   ProjectPlan({
//     required this.user,
//     required this.questions,
//   });
// }

// @MappableClass()
// class User with UserMappable {
//   final FrontEnd frontEnd;
//   // final BackEnd? backEnd;
//   User({
//     required this.frontEnd,
//     //  this.backEnd,
//   });
// }

// @MappableClass()
// class FrontEnd with FrontEndMappable {
//   final List<String> screen;
//   FrontEnd({
//     required this.screen,
//   });
// }

// @MappableClass()
// class BackEnd with BackEndMappable {
//   final List<String> api;
//   BackEnd({
//     required this.api,
//   });
// }
