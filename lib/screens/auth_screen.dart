import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/http_exception.dart';
import '../providers/auth.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          // градиент на весь экран авторизации
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.9),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 100,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Image.asset('assets/images/palm-tree.png',
                              fit: BoxFit.fill,
                              height: 120,
                              width: 120,
                              scale: 1),
                        ),
                        Text(
                          'Домашняя аптечка',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 60,
                            // fontFamily: 'Anton',
                            fontWeight: FontWeight.w100,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  AnimationController _controller;
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    // _heightAnimation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void checkEmail(String email) async {
    final random = Random();

    // Генерируйте четырёхзначный код
    int code = random.nextInt(10000);

    // Преобразуйте код в строку и добавьте нули слева, если необходимо
    String codeString = code.toString().padLeft(4, '0');
    String username = 'palm.assistance@gmail.com';
    String password = 'kxeh ahev ubgj uoen';
    final smtpServer = gmail(username, password);
    // Use the SmtpServer class to configure an SMTP server:
    // final smtpServer = SmtpServer('smtp.domain.com');
    // See the named arguments of SmtpServer for further configuration
    // options.

    // Create our message.
    final message = Message()
      ..from = Address(username, 'Домашняя аптека')
      ..recipients.add(email)
      // ..ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com'])
      // ..bccRecipients.add(Address('bccAddress@example.com'))

      ..subject = 'Код для регистрации ${DateTime.now()}'
      // ..text = 'This is the plain text.\nThis is line 2 of the text part.'
      ..html =
          "<h1>$codeString</h1>\n<p>Привет! Введите этот код в приложении</p>";

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
    showVerificationDialog(context, codeString);
  }

  Future<void> showVerificationDialog(
      BuildContext context, String codeString) async {
    String enteredCode =
        ''; // Здесь будет храниться введенный пользователем код

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Введите четырёхзначный код, который был отправлен Вам на почту',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          content: TextFormField(
            keyboardType: TextInputType.number,
            maxLength: 4,
            onChanged: (value) {
              enteredCode = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Отмена',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Применить',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () async {
                // Проверьте, совпадает ли введенный код с codeString
                if (enteredCode == codeString) {
                  await Provider.of<Auth>(context, listen: false).signup(
                    _authData['email'],
                    _authData['password'],
                  );
                  // Код совпал, выполните необходимые действия
                  // Например, закройте диалоговое окно и выполните другие операции
                  Navigator.of(context).pop();
                  // Добавьте здесь код, который должен выполниться при успешной верификации
                } else {
                  // Код не совпал, выведите сообщение об ошибке
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Неверный код. Попробуйте снова.'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in

        // почему в случае двух await один из них не работает? - потому что второй await не дожидается первого await
        // как сделать так, чтобы второй await дожидался первого await? - добавить await перед вторым await
        await Provider.of<Auth>(context, listen: false)
            .login(_authData['email'], _authData['password']);
        // await Provider.of<Profiles>(context, listen: false).func(context);
      } else {
        checkEmail(_authData['email']);
        // Sign user up
        // как отменить валидацию заполнения полей? - добавить await перед вторым await и убрать await перед первым await
        // await Provider.of<Auth>(context, listen: false).signup(
        //   _authData['email'],
        //   _authData['password'],
        // );
        // UserCredential userCredential = await FirebaseAuth.instance
        //     .createUserWithEmailAndPassword(
        //         email: _authData['email'], password: _authData['password']);
        // print("OOOOOOOOOOO");
        //print(FirebaseAuth.instance.currentUser);
        // await Provider.of<Profiles>(context, listen: false).func(context);
      }
    } on HttpException catch (error) {
      var errorMessage = 'Ошибка аутентификации';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'Данный email уже зарегистрирован';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'Данный email некорректен';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'Пароль слишком простой';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Email не найден';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Неверный пароль';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage = 'Ошибка аутентификации. Попробуйте позже';
      _showErrorDialog(errorMessage);
      print(error);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary, // added
          // border: Border.all(color: Colors.orange, width: 5), // added
          borderRadius: BorderRadius.circular(25.0),
        ),
        // color: Color.fromRGBO(55, 76, 77, 1),
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.Signup ? 320 : 260,
        // height: _heightAnimation.value.height,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  style: TextStyle(color: Theme.of(context).primaryColor),
                  decoration: InputDecoration(
                      labelText: 'Почта',
                      labelStyle:
                          TextStyle(color: Theme.of(context).primaryColor)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    // if (value.isEmpty || !value.contains('@')) {
                    //   return 'Invalid email!';
                    // }
                    if (value.isEmpty) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  style: TextStyle(color: Theme.of(context).primaryColor),
                  decoration: InputDecoration(
                      labelText: 'Пароль',
                      labelStyle:
                          TextStyle(color: Theme.of(context).primaryColor)),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    // if (value.isEmpty || value.length < 5) {
                    //   return 'Password is too short!';
                    // }
                    // if (value.isEmpty) {
                    //   return 'Password is too short!';
                    // }
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  constraints: BoxConstraints(
                    minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                    maxHeight: _authMode == AuthMode.Signup ? 120 : 0,
                  ),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                        style: TextStyle(color: Theme.of(context).primaryColor),
                        enabled: _authMode == AuthMode.Signup,
                        decoration: InputDecoration(
                            labelText: 'Подтвердите пароль',
                            labelStyle: TextStyle(
                                color: Theme.of(context).primaryColor)),
                        obscureText: true,
                        validator: _authMode == AuthMode.Signup
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match!';
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    child: Text(_authMode == AuthMode.Login
                        ? 'Войти'
                        : 'Зарегистрироваться'),
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor:
                          Theme.of(context).primaryTextTheme.button.color,
                    ),
                  ),
                TextButton(
                  child: Text(
                    '${_authMode == AuthMode.Login ? 'Зарегестрироваться' : 'Скрыть'}',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  onPressed: _switchAuthMode,
                  style: TextButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
