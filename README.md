Instructions 

1. A real device is needed to test with, not a simulator. This is because the functionality utilises a microphone.
2. To run on a real device, you'll need to select your development team in the project settings.
3. The speech recogniser is set to recognise Australian English (my own native language) - due to time constraints. Try to speak in an Australian accent ;)
4. That's it - hopefully the UI is clear enough to not need further instructions!

Notes, Limitations & Final thoughts

I originally considered building a small vocabulary set of commonly asked weather related questions, i.e., 'How is the weather today?', 'What is the weather looking like on Tuesday?'. Upon realising that the free version of the weather API I selected (openweathermap) only delivers current weather, I realised that the only variable possible would be the location. 

Since the app is specialised for current weather (hence the name WeatherNow), I then realised that having a vocabulary set is unneccesary. In English, every reasonable permutation of asking about the weather in a particular location will have that location preceded by the word "in". This vastly simplified the recognition engine I would require, and made it the only word I ended up needing to parse. 

Obviously, there are limitations to country involved here. Many city names are shared between multiple countries. Differentiating between them would require either a significantly more advanced recognition engine or a more elaborate UI with customisation settings. Either case would be outside the scope of this challenge.

Regarding tests - in Objective-C, I'm used to testing every method called from within every method and making heavy use of OCMock. In Swift, mocking isn't typically done and additionally exposing the private methods to tests would break encapsulation and require workarounds to test. Thus, I have only unit tested publically exposed methods.

Some nice to have extra features:
* German language support. I feel the "in" parsing would also work very well for the German language. The steps here would be to localise all strings in the app, incorporate device language detection, and add the relevant parameter to the API for the correct language output.
* English region support (auto switch to US, UK, AU, etc if the device language has been set to that form of English). 
* Siri integration to ask about the weather whilst the app is closed.

