## Community Questions & Answers

This file keeps track of questions and discussions from discord/forum/github in a helpful formatting.

This is not a finished FAQ section, its a work in progress, it will be merged into /docs when ready.

## Hydra

#### Is it possible to disable/enable certain flows in Hydra?

>andrius#9992 09-Jan-20 09:50    
>Is it possible to leave only OpenID authorization code grant flow, while disabling all the rest of the flows in Hydra? Is it configurable that way?   

Yes - you can configure that in your client.
It has things like grant_types etc - there you can basically whitelist the flows you need.


#### How can i test if my 4445 is running properly?
>RoytBerge 30-Dec-19 12:57  
>I am setting up a reaction commerce platform. I am using ory hydra for authentication. 
I get a 404 when im trying to create a client on my private EC2 hydra task. Is there a way to test if my 4445 is running properly?   
It returns a 404 not found message when i go to the root *:4445, but i think hydra is meant to return this 404, so i am looking for another way of making sure my hydra task is running properly.

You can check /health/alive, to see if it's alive.
and /health/ready, to see if it's also in ready state (meaning db connectivity works).
