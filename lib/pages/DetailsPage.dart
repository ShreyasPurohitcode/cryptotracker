import 'dart:developer';

import 'package:cryptotracker/models/Cryptocurrency.dart';
import 'package:cryptotracker/models/GraphPoint.dart';
import 'package:cryptotracker/providers/graph_provider.dart';
import 'package:cryptotracker/providers/market_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DetailsPage extends StatefulWidget {
  final String id;

  const DetailsPage({Key? key, required this.id}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {

  Widget titleAndDetail(String title, String detail, CrossAxisAlignment crossAxisAlignment) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [

        Text(title, style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17
        ),),

        Text(detail, style: TextStyle(
          fontSize: 17
        ),),

      ],
    );
  }

  late GraphProvider graphProvider;

  int days = 1;
  List<bool> isSelected = [true, false, false, false];

  void toggleDate(int index) async {

    log("Loading....");

    for(int i=0; i<isSelected.length; i++) {
      if(i == index) {
        isSelected[i] = true;
        log(isSelected.toString());
      }
      else {
        isSelected[i] = false;
        log(isSelected.toString());
      }
    }

    switch (index) {
      case 0:
        days = 1;
        break;
      case 1:
        days = 7;
        break;
      case 2:
        days = 28;
        break;
      case 3:
        days = 90;
        break;
      default:
        break;
    }

    await graphProvider.initializeGraph(widget.id, days);

    setState(() {});

    log("Graph Loaded!");
  }

  void initializeInitialGraph() async {
    log("Loading Graph...");

    await graphProvider.initializeGraph(widget.id, days);
    setState(() {});

    log("Graph Loaded!");
  }

  @override
  void initState() {
    super.initState();

    graphProvider = Provider.of<GraphProvider>(context, listen: false);
    initializeInitialGraph();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: ListView(
              physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()
                  ),
              children: [

                ToggleButtons(
                  onPressed: (index) {
                    toggleDate(index);
                  },
                  children: [
                    Text("1D"),

                    Text("7D"),

                    Text("28D"),

                    Text("90D"),
                  ],
                  isSelected: isSelected,
                ),

                SizedBox(height: 20,),
                
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                  child: SfCartesianChart(
                    primaryXAxis: DateTimeAxis(),
                    series: <AreaSeries>[

                      AreaSeries<GraphPoint, dynamic>(
                        color: Color(0xff1ab7c3).withOpacity(0.5),
                        borderColor: Color(0xff1ab7c3),
                        borderWidth: 2,
                        dataSource: graphProvider.graphPoints,
                        xValueMapper: (GraphPoint graphPoint, index) => graphPoint.date,
                        yValueMapper: (GraphPoint graphpoint, index) => graphpoint.price
                      ),

                    ],
                  ),
                ),

                Consumer<MarketProvider>(
                  builder: (context, marketProvider, child) {

                    CryptoCurrency currentCrypto = marketProvider.fetchCryptoById(widget.id);

                    return ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [

                        ListTile(
                          contentPadding: EdgeInsets.all(0),
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(currentCrypto.image!),
                          ),
                          title: Text(currentCrypto.name! + " (${currentCrypto.symbol!.toUpperCase()})", style: TextStyle(
                            fontSize: 20,
                          ),),
                          subtitle: Text("₹ " + currentCrypto.currentPrice!.toStringAsFixed(4), style: TextStyle(
                            color: Color(0xff0395eb),
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                          ),),
                        ),

                        SizedBox(height: 20,),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text("Price Change (24h)", style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            ),),

                            Builder(
                              builder: (context) {
                                double priceChange = currentCrypto.priceChange24!;
                                double priceChangePercentage = currentCrypto.priceChangePercentage24!;

                                if(priceChange < 0) {
                                  // negative
                                  return Text("${priceChangePercentage.toStringAsFixed(2)}% (${priceChange.toStringAsFixed(4)})", style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 23
                                  ),);
                                }
                                else {
                                  // positive
                                  return Text("+${priceChangePercentage.toStringAsFixed(2)}% (+${priceChange.toStringAsFixed(4)})", style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 23
                                  ),);
                                }
                              },
                            ),

                          ],
                        ),


                        SizedBox(height: 30,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            titleAndDetail("Market Cap", "₹ " + currentCrypto.marketCap!.toStringAsFixed(4), CrossAxisAlignment.start),

                            titleAndDetail("Market Cap Rank", "#" + currentCrypto.marketCapRank.toString(), CrossAxisAlignment.end),

                          ],
                        ),

                        SizedBox(height: 20,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            titleAndDetail("Low 24h", "₹ " + currentCrypto.low24!.toStringAsFixed(4), CrossAxisAlignment.start),

                            titleAndDetail("High 24h", "₹ " + currentCrypto.high24!.toStringAsFixed(4), CrossAxisAlignment.end),

                          ],
                        ),

                        SizedBox(height: 20,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            titleAndDetail("Circulating Supply", currentCrypto.circulatingSupply!.toInt().toString(), CrossAxisAlignment.start),

                          ],
                        ),

                        SizedBox(height: 20,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            titleAndDetail("All Time Low", currentCrypto.atl!.toStringAsFixed(4), CrossAxisAlignment.start),

                            titleAndDetail("All Time High", currentCrypto.ath!.toStringAsFixed(4), CrossAxisAlignment.start),

                          ],
                        ),

                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}