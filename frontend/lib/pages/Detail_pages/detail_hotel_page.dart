import 'package:frontend/models/hotel.dart';
import 'package:frontend/pages/Detail_pages/detail_room_page.dart';

class DetailHotelScreen extends StatefulWidget {
  // final Room room{};
  final Hotel hotel;
  final String? imageUrl;

  const DetailHotelScreen({super.key, this.imageUrl});

  @override
  State<DetailHotelScreen> createState() => _DetailHotelScreenState();
}

class _DetailHotelScreenState extends State<DetailHotelScreen> {
  //   ListView.builder(
  //   itemCount: _rooms.length,
  //   itemBuilder: (context, index) {
  //     final room = _rooms[index];
  //     final firstImage = _roomImages[room.id];

  //     return RoomCard(          // ← put here
  //       room: room,
  //       imageUrl: firstImage,
  //       onSelectRoom: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => DetailRoomPage(room: room),
  //           ),
  //         );
  //       },
  //     );
  //   },
  // ),
}
