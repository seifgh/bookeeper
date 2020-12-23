import 'dart:io';
import 'package:bookeeper/data_providers/user.dart';
import 'package:bookeeper/screens/home.dart';
import 'package:bookeeper/data_providers/web_api.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';

import 'package:bookeeper/screens/sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bookeeper/utils/validators.dart';
import 'package:flutter/services.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key key}) : super(key: key);

  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _emailController = TextEditingController(),
      _passwordController = TextEditingController(),
      _fullNameController = TextEditingController();
  File _image;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  bool _signUpIsLoading = false, _imageIsLoading = false;

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();

    super.dispose();
  }

  bool _obscurePass = true;
  void _toggleObsecurePass() {
    setState(() {
      _obscurePass = !_obscurePass;
    });
  }

  Future _getImage(ImageSource source) async {
    try {
      setState(() {
        _imageIsLoading = true;
      });
      PickedFile pickedFile;

      pickedFile = await picker.getImage(source: source);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        final imageExtention =
            pickedFile.path.substring(pickedFile.path.lastIndexOf("."));
        int imageSize = await _image.length();
        // show error if size > 5mb
        if (imageSize > 5 * 1024 * 1024) {
          _image = null;
          _scaffoldKey.currentState.showSnackBar(SnackBar(
              duration: Duration(seconds: 8),
              backgroundColor: Colors.red,
              content: Text(
                "Image size is too large, size should be under 5mb!",
              ),
              action: SnackBarAction(
                label: "ClOSE",
                onPressed: () {
                  _scaffoldKey.currentState.hideCurrentSnackBar();
                },
              )));
        }
      }
      setState(() {
        _imageIsLoading = false;
      });
    } catch (e) {
      // permissions errors
      setState(() {
        _imageIsLoading = false;
      });
    }
  }

  _signUpOnTap(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _signUpIsLoading = true;
      });

      final res = await webApi.signUp(_fullNameController.text,
          _emailController.text, _passwordController.text, _image);

      if (res.isSuccessful) {
        await user.update("auth", res.body['user']);
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (ctx) => HomeScreen()));
        return;
      } else if (res.hasNetworkError) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
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
              res.body['errors'] == null
                  ? "We have a technical problem, please try later!"
                  : "A user with this email already exists!",
            ),
            action: SnackBarAction(
              label: "ClOSE",
              onPressed: () {
                _scaffoldKey.currentState.hideCurrentSnackBar();
              },
            )));
      }
      setState(() {
        _signUpIsLoading = false;
      });
    }
  }

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
                                    Text('Sign Up',
                                        style: theme.textTheme.headline1
                                            .apply(color: theme.primaryColor)),
                                    const SizedBox(
                                      height: 24,
                                    ),
                                    InkWell(
                                      onTap: () =>
                                          _getImage(ImageSource.gallery),
                                      child: _imageIsLoading
                                          ? SizedBox(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        theme.primaryColor),
                                              ),
                                              height: 80,
                                              width: 80,
                                            )
                                          : (_image == null
                                              ? Image.asset(
                                                  "assets/images/user.png",
                                                  width: 80,
                                                )
                                              : CircleAvatar(
                                                  radius: 80,
                                                  backgroundImage: FileImage(
                                                    _image,
                                                  ))),
                                    ),
                                    const SizedBox(
                                      height: 24,
                                    ),
                                    Text("Profile image ( Optionnel )"),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        RaisedButton(
                                          onPressed: () =>
                                              _getImage(ImageSource.gallery),
                                          textColor: theme.accentColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text("Gallery"),
                                        ),
                                        const SizedBox(
                                          width: 16,
                                        ),
                                        OutlineButton(
                                          onPressed: () =>
                                              _getImage(ImageSource.camera),
                                          textColor: theme.primaryColor,
                                          color: theme.accentColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text("Camera"),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 24,
                                    ),
                                    TextFormField(
                                      controller: _fullNameController,
                                      keyboardType: TextInputType.emailAddress,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                            RegExp(r"\s\s"))
                                      ],
                                      validator: fullNameFieldValidator,
                                      decoration: InputDecoration(
                                          border: const OutlineInputBorder(),
                                          fillColor: Colors.white,
                                          filled: true,
                                          labelText: 'Full name',
                                          hintText: 'Enter your full name',
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
                                      onPressed: _signUpIsLoading
                                          ? null
                                          : () => _signUpOnTap(context),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 18),
                                      textColor: theme.accentColor,
                                      disabledColor: theme.accentColor,
                                      color: theme.primaryColor,
                                      child: _signUpIsLoading
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
                                              'Sign up',
                                            ),
                                    ),
                                    const SizedBox(
                                      height: 52,
                                    ),
                                    Center(
                                        child: Text(
                                      'You have an account ?',
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
                                                      SignInScreen()));
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
                                          'Sign in',
                                        ),
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
