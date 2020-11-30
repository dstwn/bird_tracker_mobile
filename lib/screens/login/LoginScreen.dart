class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RaisedButton(
          child: Text("Sign In"),
          onPressed: () {
            Auth().signInUserWithGoogle();
          },
        ),
      ),
    );
  }
}
