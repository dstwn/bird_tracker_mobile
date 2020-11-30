class Root extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User _user = Provider.of<User>(context);

    // return (_user != null)
    //     ? StreamProvider<List<Book>>.value(
    //         value: Database().books, child: Home())
    //     : Login();
  }
}
