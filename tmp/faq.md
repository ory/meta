## Community Questions & Answers

This file keeps track of questions and discussions from discord/forum/github in a helpful formatting.

This is not a finished FAQ section, its a work in progress, it will be merged into /docs when ready.



#### Is it possible to disable/enable certain flows in Hydra?

>andrius#9992  09-Jan-20 09:50    
>Is it possible to leave only OpenID authorization code grant flow, while disabling all the rest of the flows in Hydra? Is it configurable that way?   

Yes - you can configure that in your client.
It has things like grant_types etc - there you can basically whitelist the flows you need.
