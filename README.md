So let's get this going — here's what I need.

Basically what I need is a script inside Discourse to manage users and to give them a specific time limit for access.

So if someone buys product X for example, a new user will be created inside there to give them access for 1 year.

That's the overall view. Now let's get to the details:


➠ THE SCRIPT

My idea is to create a custom script that we will instal inside Discourse like any other scripts they have.

Then I believe the best place to show a menu for it inside Discourse is either one of the top menus inside the "Admin" panel OR a item on the left menu inside "Settings". I'll later send you screenshots of what I mean.

I believe we can change to fit in one of these places. But if perhaps it's mandatory that it only shows inside the "Plugins" menu inside "Settings", then it's ok too. I prefer a separate menu for it, but it doesn't really matter.


➠ HOW IT SHOULD WORK

What I have is that each time there's a sale, my payment processor sends a POST notification with the info about this sale itself. It will send some custom parameters, but the ones we will be working with are the following:

token, product_id, email, offer, status, name

The name we can add later on as it's just a nice thing to already have the script type the right name for the user. But to start off let's focus on the other ones: token, product_id, email, offer and status.

	- Token: this is the API token to recognize that the POST notification came from the right place;
	- Product_id: this is to identify the product bought;
	- Email: their email when they bought it;
	- Offer: to identify which special offer inside the product they bought;
	- Status: this will either be "approved" or "refunded" (there's actually more, but we will use only these 2).

My idea is as follows:

I can set that this POST notification can be sent to any link I want. So we'll create a file or a script to receive these notifications like http://comunidade.nacaolifestyle.com/plugins/user-admin.php (this is just as an example).

Within this URL, it will gather the data I specified above and manager the user status following this rules:

	- If the status sent is "approved", first check based on their EMAIL, for the following conditions:
		- If it's a new user, create a new username following the guidelines below;
		- If the user already exists, increase his time access by X amounts of month which we will specify later;
	- If the status sent is "refunded" then remove access from the user (based on its email) WITHOUT deleting the user (as to not delete his posts);

When creating new users, use the following as a rule:
	
	- Use the first part of the email as their username. So if the email is "bruno123@gmail.com", the username will be "bruno123";
	- If the user already exists, then just add a "1" at the end of it. In this example, the second user with the same email would be "bruno1231"

That's the basic idea for the backend of the script.

Now let's talk on how this will work on the frontend:


➠ FRONTEND

As I said, I'd like to have an extra menu inside Discourse. Preferably a new top menu in the "Admin" panel or a new menu on the left sidebar menu inside "Settings".

Inside there, I'd like to be able to set custom rules for this to work.

I think the easiest way to do this is to have a custom space where I could type separated by "," what I want to check and what the script should do.

So it would look like something like this:

"Please type separated by commas the following in order: token, product_it, offer"

Then in a box below I'd type something like:

"2JNVF6MU0XOWXGG, 87615, aa987xy"

Right by its side there would be a dropdown to choose to which GROUP the user should be added (certainly there is a way to get this data from the site itself as I've seen working in other places inside Discourse. I can point out to you later).

Right next to this there should be a dropdown which I can select "Approved" or "Refunded". And based on this it should show the correct box right by its side (or just ignore the next box).

Then right next there should be a box that would say "How many months should the access be?". In this box I can type how many months exactly I want the person to access my community before expiring.

	If the status selected is approved, then this box should work.
	If the status selected is refunded, then the script can safely ignore that data as we are not giving access, we are actually removing it.

Makes sense?

So that first part was so the script should check for POST notifications to our URL which has the info specified above. If it does, it should proceed with the rest of the script.

So it would like something like:

Rules | Status | Group | Access (in months)

Where I would type all that and then click "Add" to add this new rule.

After this new rule is saved, there should also be a "X" button so that I can delete this rule in case I need to change something.

Other things to consider:

	- Please also create a rule that if  I insert "0" (or any other symbol you want) as one of the parameters, then this mean that ALL parameters will be accepted. Example:

token, product_it, offer

"2JNVF6MU0XOWXGG, 87615, 0"

That means that no matter which parameter is sent for "offer", it will still proceed with the rule to do what it should do.

	- I also would like that inside the script, there's a place where I can manually change a user time access or status.
		- So inside the same screen there would be some options like:

"Type username that you want to search:"

This would search in the database for the username.

Right next there would be options to choose like: "Extend access in ___ months" (where I could type how many months I want) or "Suspend access".

	- It would also be nice if we can show to the user how many days he has left and what date exactly his subscription will expire.
		- In order for this to work, we need to add a custom information to show inside the profile's page of each user which will gather data from him and then show that info of how much time he has left.
		- This is not super important as the rest. So let's first get the script working and then we can do stuff like this and also to get the name from the POST notification to already insert that for the new user.



➠ ACCESS

Right now I have to leave. But I'll send you all the login details later on so we can get this going.

At the moment can you carefully read the instructions here and see if you have any questions.

You can also start investigating in Discourse to find out what you will need to accomplish all this.

Then later on I'll send you all the access info and we can get started :)

Thanks!
-Bruno

