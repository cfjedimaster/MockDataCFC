component {

	cfheader(name="Access-Control-Allow-Origin", value="*");
	
	//So you can skip passing it...
	url.method="mock";

	//Defaults used for data, may move to a file later
	fNames = ["Andy","Alice","Amy","Barry","Bob","Charlie","Clarence","Clara","Danny","Delores","Erin","Frank","Gary","Gene","George","Heather","Jacob","Leah","Lisa","Lynn","Nick","Noah","Ray","Roger","Scott","Todd"];
	lNames = ["Anderson","Bearenstein","Boudreaux","Camden","Clapton","Degeneres","Hill","Moneymaker","Padgett","Rogers","Smith","Sharp","Stroz","Zelda"];
	emailDomains = ["gmail.com","aol.com","microsoft.com","apple.com","adobe.com"];
	lorem = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

	defaults = ["name","fname","lname","age","all_age","email","ssn","tel","gps","num"];
	function isDefault(s) {
		return defaults.findNoCase(s) >= 0; 
	}

	function generateFirstName() {
		return fNames[randRange(1, fNames.len())];
	}

	function generateLastName() {
		return lNames[randRange(1, lNames.len())];
	}

	function generateFakeData(type) {
		if(type == "string") return "string";
		if(type == "name") return generateFirstName() & " " & generateLastName();
		if(type == "fname") return generateFirstName();
		if(type == "lname") return generateLastName();
		if(type == "age") return randRange(18,75);
		if(type == "all_age") return randRange(1,100);
		if(type == "email") {
			var fname = generateFirstName().toLowerCase();
			var lname = generateLastName().toLowerCase();
			var emailPrefix = fname.charAt(1) & lname;
			return emailPrefix & "@" & emailDomains[randRange(1, emailDomains.len())];
		}
		if(type == "ssn") {
			return randRange(1,9) & randRange(1,9) & randRange(1,9) & "-" &
				    randRange(1,9) & randRange(1,9) & "-" & 
				    randRange(1,9) & randRange(1,9) & randRange(1,9) & randRange(1,9);
		}
		if(type == "tel") {
			return "(" & randRange(1,9) & randRange(1,9) & randRange(1,9) & ") " &
				    randRange(1,9) & randRange(1,9) & randRange(1,9) & "-" & 
				    randRange(1,9) & randRange(1,9) & randRange(1,9) & randRange(1,9);
	
		}
		if(type.find("num") == 1) {
			//Support num, num:10, num:1:10
			if(type == "num") return randRange(1,10);
			if(type.find(":") > 1) {
				var parts = type.listToArray(":");
				if(parts.len() == 2) return randRange(1,parts[2]);
				else return randRange(parts[2],parts[3]);
			}
		}
		if(type.find("oneof") == 1) {
			//Support oneof:male:female, ie, pick a random one
			var items = type.listToArray(":");
			items.deleteAt(1);
			return items[randRange(1,items.len())];
		}
		if(type.find("lorem") == 1) {
			if(type == "lorem") return lorem;
			if(type.find(":") > 1) {
				var parts = type.listToArray(":");
				var result = "";
				var count = "";
				if(parts.len() == 2) count = parts[2];
				else count = randRange(parts[2],parts[3]);
				for(var i=0; i<count; i++) result &= lorem & "\n\n";
				return result;
			}
		}
		return "";
	}

	function generateNewItem(model) {
		var result = {};

		model.each(function(field) {
			if(!field.keyExists("name")) {
				field.name = "field"&i;
			}
	
			if(!field.keyExists("type")) {
				//if we are a default, that is our type, otherwise string
				if(isDefault(field.name)) field.type = field.name;
			}
			result[field.name] = generateFakeData(field.type);
			
		});
		
		return result;
	}
	
	remote function mock() returnformat="json" {
		
		//Did they specify how many they want?
		if(!arguments.keyExists("num")) arguments.num = 10;

		if(!isNumeric(arguments.num) && arguments.num.find(":") > 0) {
			var parts = arguments.num.listToArray(":");
			if(parts[1] != "rnd") {
				throw("Invalid num prefix sent. Must be 'rnd'");
			}
			// format is rnd:10 which means, from 1 to 10
			if(parts.len() == 2) {
				arguments.num = randRange(1,parts[2]);
			} else {
				arguments.num = randRange(parts[2],parts[3]);
			}
		}

		var fieldModel = [];
		for(var key in arguments) {
			if(key != "num") {
				fieldModel.append({name:key,type:arguments[key]});
			}
		}
	
		var result = [];
		for(var i=1; i<=arguments.num; i++) {
			result.append(generateNewItem(fieldModel));
		}
			
		cfheader(name="Content-Type", value="application/json");

		return result;
	}

}