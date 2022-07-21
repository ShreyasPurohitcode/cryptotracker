import 'package:cryptotracker/models/GraphPoint.dart';
import 'package:cryptotracker/services/API.dart';
import 'package:flutter/cupertino.dart';

class GraphProvider with ChangeNotifier {

  List<GraphPoint> graphPoints = [];

  Future<void> initializeGraph(String id, int days) async {
    List<dynamic> priceData = await API.fetchGraphData(id, days);

    List<GraphPoint> temp = [];
    for(var pricePoint in priceData) {
      GraphPoint graphPoint = GraphPoint.fromList(pricePoint);
      temp.add(graphPoint);
    }

    graphPoints = temp;
    notifyListeners();
  }

}