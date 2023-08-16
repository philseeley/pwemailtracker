import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatelessWidget {

  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help")),
      body: MarkdownWidget(
        config: MarkdownConfig(configs: [LinkConfig(onTap: openURL)]),
        data: '''
# Email Tracker
Predefined templates sre provided for well known tracking applications and destinations.

Contact [Phil](mailto:feedback@wheretofly.info?subject=EMail%20Tracker%20Feedback) if you would like a template added.

## Predict Wind
The "Username" is required to be your account email address, but emails can be sent from any address.

## No Foreign Land
Make sure the email you send from is configured in the web app, see [https://www.noforeignland.com/help/boat/move-email](https://www.noforeignland.com/help/boat/move-email)

## Des Cason
Des is a weather router from South Africa. Set the "Username" to your name(s) and the "Password" to your boat name.

After you've engaged Des set his email address in the "Destination Email" field.

## Custom
You can define custom email body and subject templates using the following fields:
- {lat<loc format>}
- {lon<loc format>}
- {local<time format>}
- {utc<time format>}
- {tz[separator]}
- {user}
- {pass}

Where:
**<loc format>** can be:
- [0]d -- degrees
- [0]d.d[ddd] -- decimal degrees
- [0]m -- minutes
- [0]m.m[mmm] -- decimal minutes
- [0]s -- seconds
- [0]s.s[sss] -- decimal seconds
- c -- cardinal direction, i.e. N,S,E or W.
- \\- -- a "-" when South or West.
- \\+ -- a "+" when North or East and "-" when South or West.

A leading "0" will pad the field to a fixed length.

**<time format>** can be anything defined [here](https://api.flutter.dev/flutter/intl/DateFormat-class.html).

Use "\\n" to insert line breaks.

For example the template:

Hi there,\\n\\nOn {utcyyyy-MM-dd} at {utcHH:mm} UTC, {pass} is at:\\n\\n{latd m.mmm c}, {lond m.mmm c}\\n\\nCheers\\n{user}

Would produce:

Hi there,

On 2023-08-16 at 19:02 UTC, SV Billy Do is at:

5 3.544 S, 39 7.043 E

Cheers
Joe Blogs
''')
    );
  }

  openURL(url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

}
