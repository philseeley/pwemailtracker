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
Set the location "Accuracy" appropriate for you. You can email or share the data when your location has been accurately obtained.

On Android, if "Auto Close" is enabled, the app will close once the "EMail" or "Share" buttons have been pressed.

Predefined templates sre provided for well known tracking applications and destinations.

Contact [Phil](mailto:feedback@wheretofly.info?subject=EMail%20Tracker%20Feedback) if you would like a template added.

## Predict Wind
The first line of "Identity" is required to be your account email address, but emails can be sent from any address.

## No Foreign Land
Make sure the email you send from is configured in the web app, see [https://www.noforeignland.com/help/boat/move-email](https://www.noforeignland.com/help/boat/move-email)

## Weather Router
After you've engaged a weather router set his email address in the "Destination Email" field and
set three lines of "Identity" to your name(s), your boat name and your router's name.

## Custom
**Note:** you can copy a pre-defined template using the "Copy" button.

You can define custom email body and subject templates using the following fields:
- {lat<loc format>} -- Latitude.
- {lon<loc format>} -- Longitude.
- {local<time format>} -- Local time.
- {utc<time format>} -- Time in UTC.
- {tz[separator]} -- Local Time Zone, of the form "+05[separator]30".
- {ident[index]} -- Identity information line indexed from 0 (0 is optional). 

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

### For example:

With three lines of Identity:
  Joe Blogs
  SV Billy Do
  Fred

The template:
```
Hi {ident2},

On {utcyyyy-MM-dd} at {utcHH:mm} UTC, {ident1} is at:

{latd m.mmm c}, {lond m.mmm c}

Cheers
{ident}
```
Would produce:
```
Hi Fred,

On 2023-08-16 at 19:02 UTC, SV Billy Do is at:

5 3.544 S, 39 7.043 E

Cheers
Joe Blogs
```
''')
    );
  }

  openURL(url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

}