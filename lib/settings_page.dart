import 'package:erthquake_app/providers/app_data_provider.dart';
import 'package:erthquake_app/utils/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _magController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Consumer<AppDataProvider>(
        builder: (context, provider, child) => ListView(
          padding:const EdgeInsets.all(8.0),
          children: [
            Text("Time Settings", style: Theme.of(context).textTheme.titleMedium,),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text("Start Time"),
                    subtitle: Text(provider.startTime),
                    trailing: IconButton(
                      onPressed: ()async{
                      final date =  await selectDate();
                        if(date != null){
                          provider.setStartTime(date);
                        }
                      },
                      icon: const Icon(Icons.calendar_month),
                    ),
                  ),
                  ListTile(
                    title: const Text("End Time"),
                    subtitle: Text(provider.endTime),
                    trailing: IconButton(
                      onPressed: ()async{
                      final date =  await selectDate();
                        if(date != null){
                          provider.setEndTime(date);
                        }
                      },
                      icon: const Icon(Icons.calendar_month),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: (){
                        provider.getEarthquakeData();
                        showMsg(context, "Times are Updated");
                      },
                      child: const Text("Update Time")),
                ],
              ),
            ),
            Text("Change Magnitude",style: Theme.of(context).textTheme.titleMedium,),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text("Magnitude"),
                    subtitle: Text("mag ${provider.minmagnitude}"),
                    trailing: SizedBox(
                      width: 30,
                      height: 20,
                      child: TextFormField(
                        controller: _magController,
                        textAlign: TextAlign.center,
                        onChanged: (value){
                          provider.setMagnitude(value);
                        },
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: ()async{
                        await provider.getEarthquakeData();
                        showMsg(context, "Magnitude are Updated");
                      },
                      child: const Text("Update Magnitude")),
                ],
              ),
            ),
            Text("Location Setting",style: Theme.of(context).textTheme.titleMedium,),
            Card(
              child: SwitchListTile(
                title: Text(provider.currentCity ?? "Your city is unknown"),
                subtitle: provider.currentCity == null ? null : Text("Earthquake data will be shown within ${provider.maxRadiusKm } km radius from ${provider.currentCity}"),
                value: provider.shouldUseLocation,
                onChanged: (value)async{
                  EasyLoading.show(status: "Getting device location...");
                  await provider.setLocation(value);
                  EasyLoading.dismiss();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<String?> selectDate()async {
  final dt = await  showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
    );
    if(dt != null){
      return getFormattedDateTime(dt.millisecondsSinceEpoch);
    }
    return null;

  }
}
