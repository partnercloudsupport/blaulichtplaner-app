import 'package:blaulichtplaner_app/widgets/no_employee.dart';
import 'package:blaulichtplaner_lib/blaulichtplaner.dart';
import 'package:flutter/material.dart';

class RolesScreen extends StatelessWidget {
  final List<CompanyEmployeeRole> companyRoles;

  RolesScreen({Key key, @required this.companyRoles}) : super(key: key);

  Widget _tileBuilder(BuildContext context, CompanyEmployeeRole role) {
//    String sinceLabel = 'Seit ' + DateFormat.yMMM("de_DE").format(role.created);
    return ListTile(
      title: Text(role.label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Zugeordnete Firmen"),
      ),
      body: companyRoles.length > 0
          ? ListView.builder(
              itemCount: companyRoles.length,
              itemBuilder: (BuildContext context, int index) {
                return _tileBuilder(context, companyRoles[index]);
              },
            )
          : NoEmployee(),
    );
  }
}
