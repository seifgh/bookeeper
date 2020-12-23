import 'package:bookeeper/data_providers/user.dart';
import 'package:bookeeper/screens/home.dart';
import 'package:bookeeper/screens/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home.dart';
import '../utils/validators.dart'
    show emailFieldValidator, passwordFieldValidator;
import '../data_providers/web_api.dart';

class SignInScreen extends StatefulWidget {
  SignInScreen({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _signInIsLoading = false, _isGeustIsLoading = false;
  final _emailController = TextEditingController(),
      _passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _obscurePass = true;
  void _toggleObsecurePass() {
    setState(() {
      _obscurePass = !_obscurePass;
    });
  }

  _signInOnTap(BuildContext context) async {
    _scaffoldKey.currentState.hideCurrentSnackBar();
    // validate data
    if (_formKey.currentState.validate()) {
      setState(() {
        _signInIsLoading = true;
      });
      final res =
          await webApi.signIn(_emailController.text, _passwordController.text);

      if (res.isSuccessful) {
        print(res.body);
        await user.update("auth", res.body['user']);
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (ctx) => HomeScreen()));
        return;
      } else if (res.hasNetworkError) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            duration: Duration(seconds: 8),
            backgroundColor: Colors.red,
            content: Text(
              "Some thing went wrong, please check your network!",
            ),
            action: SnackBarAction(
              label: "ClOSE",
              onPressed: () {
                _scaffoldKey.currentState.hideCurrentSnackBar();
              },
            )));
      } else if (res.hasServerError) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            duration: Duration(seconds: 8),
            backgroundColor: Colors.red,
            content: Text(
              "We have a technical problem, please try later!",
            ),
            action: SnackBarAction(
              label: "ClOSE",
              onPressed: () {
                _scaffoldKey.currentState.hideCurrentSnackBar();
              },
            )));
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            duration: Duration(seconds: 8),
            backgroundColor: Colors.red,
            content: Text(
              "Incorrect username or password, please try again!",
            ),
            action: SnackBarAction(
              label: "ClOSE",
              onPressed: () {
                _scaffoldKey.currentState.hideCurrentSnackBar();
              },
            )));
      }
      setState(() {
        _signInIsLoading = false;
      });
    }
  }

  _continueAsGeustOntap(BuildContext context) async {
    // prevent clicking signin then continue as a geust
    if (!_signInIsLoading) {
      setState(() {
        _isGeustIsLoading = true;
      });
      await user.update("guest");
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (ctx) => HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          shadowColor: Colors.transparent,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text('BooKeeper',
              style: theme.textTheme.headline2.apply(color: Colors.white)),
        ),
        body: Stack(
          children: [
            SizedBox.expand(
                child: Container(
              color: theme.primaryColor,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to BooKeeper!',
                      style:
                          theme.textTheme.headline2.apply(color: Colors.white),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      'Please sign-in or create an account to continue.',
                      style:
                          theme.textTheme.headline6.apply(color: Colors.white),
                    )
                  ],
                ),
              ),
            )),
            DraggableScrollableSheet(
                initialChildSize: 0.85,
                minChildSize: 0.85,
                maxChildSize: 1,
                builder: (context, scrollController) => Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24))),
                      child: SingleChildScrollView(
                          controller: scrollController,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 24),
                            child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text('Sign In',
                                        style: theme.textTheme.headline1
                                            .apply(color: theme.primaryColor)),
                                    const SizedBox(
                                      height: 24,
                                    ),
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                            RegExp(r"\s"))
                                      ],
                                      validator: emailFieldValidator,
                                      decoration: InputDecoration(
                                          border: const OutlineInputBorder(),
                                          fillColor: Colors.white,
                                          filled: true,
                                          labelText: 'Email',
                                          hintText: 'Enter your email',
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  16.0, 20.0, 16.0, 20.0),
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                  color: Colors.black12,
                                                  width: 0))),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    TextFormField(
                                      controller: _passwordController,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                            RegExp(r"\s")),
                                        LengthLimitingTextInputFormatter(128)
                                      ],
                                      validator: passwordFieldValidator,
                                      obscureText: _obscurePass,
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        fillColor: Colors.white,
                                        filled: true,
                                        labelText: 'Password',
                                        hintText: 'Enter your password',
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                16.0, 20.0, 16.0, 20.0),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Colors.black12,
                                                width: 0)),
                                        suffixIcon: IconButton(
                                          icon: Icon(_obscurePass
                                              ? Icons.visibility_off
                                              : Icons.visibility),
                                          onPressed: _toggleObsecurePass,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 24,
                                    ),
                                    FlatButton(
                                      minWidth: double.infinity,
                                      onPressed: _signInIsLoading
                                          ? null
                                          : () => _signInOnTap(context),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 18),
                                      textColor: theme.accentColor,
                                      disabledColor: theme.accentColor,
                                      color: theme.primaryColor,
                                      child: _signInIsLoading
                                          ? SizedBox(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        theme.primaryColor),
                                              ),
                                              height: 18,
                                              width: 18,
                                            )
                                          : Text(
                                              'Sign in',
                                            ),
                                    ),
                                    const SizedBox(
                                      height: 52,
                                    ),
                                    Center(
                                        child: Text(
                                      'Dont’t have an account ?',
                                      style: theme.textTheme.headline3
                                          .apply(color: Colors.black),
                                    )),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Container(
                                      decoration:
                                          const BoxDecoration(boxShadow: [
                                        const BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 5.0,
                                        ),
                                      ]),
                                      child: FlatButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (ctx) =>
                                                      SignUpScreen()));
                                        },
                                        minWidth: double.infinity,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 16),
                                        textColor: theme.primaryColor,
                                        color: theme.accentColor,
                                        child: Text(
                                          'Create an account',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Center(
                                        child: Text(
                                      'OR',
                                      style: theme.textTheme.headline6
                                          .apply(color: Colors.black),
                                    )),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    FlatButton(
                                      onPressed: () =>
                                          _continueAsGeustOntap(context),
                                      minWidth: double.infinity,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 16),
                                      textColor: theme.accentColor,
                                      color: theme.primaryColor,
                                      child: _isGeustIsLoading
                                          ? SizedBox(
                                              child:
                                                  CircularProgressIndicator(),
                                              height: 18,
                                              width: 18,
                                            )
                                          : Text(
                                              'Continue as a guest',
                                            ),
                                    ),
                                  ],
                                )),
                          )),
                    )),
          ],
        ));
  }
}
