import 'package:flutter/material.dart';
import 'package:music_app/Values.dart';
import 'package:provider/provider.dart';

import 'DataModel.dart';
import 'Sorting.dart';

class SortDropdown extends StatefulWidget {
  const SortDropdown({Key? key}) : super(key: key);

  @override
  _SortDropdownState createState() => _SortDropdownState();
}
class _SortDropdownState extends State<SortDropdown> {
  SortType currentSort = SortType.AZ;
  @override
  Widget build(BuildContext context) {
    setState(() {
      currentSort = Provider.of<DataModel>(context, listen:false).settings.sort;
    });
    return Padding(
      padding: const EdgeInsets.only(right: Dimens.xSmall),
      child: DropdownButton<String>(
        value: sortingToString(currentSort),
        icon: const Icon(Icons.arrow_downward),
        iconSize: 24,
        elevation: 16,
        iconEnabledColor: Colours.secondaryColour,
        underline: Container(
          height: 2,
          color: Theme.of(context).colorScheme.secondary,
        ),
        onChanged: (String? newValue) {
          setState(() {
            currentSort = stringToSorting(newValue!);
          });
          Provider.of<DataModel>(context, listen:false).sortSongs(currentSort);
        },
        items: [sortingToString(SortType.AZ),sortingToString(SortType.ZA), sortingToString(SortType.ShortestFirst), sortingToString(SortType.LongestFirst)]
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}