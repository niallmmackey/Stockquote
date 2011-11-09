class StockController < ApplicationController
	require 'rubygems'
     	require 'json'
     	require 'net/http'
    
    
     	def lookup
     	  	stocksymbol = params[:StockSymbol]
     	  	stocksymbol.upcase.gsub!(/![A-Z]/, "")
     
          	stockhash = Hash.new;
          	stocksresults = get_yql_data(stocksymbol);
          	stockhash["Symbol"] = stocksresults["query"]["results"]["quote"]["symbol"];
          	stockhash["Ask"] = stocksresults["query"]["results"]["quote"]["Ask"];
          	stockhash["Name"] = stocksresults["query"]["results"]["quote"]["Name"];
          	stockhash["Change"] = stocksresults["query"]["results"]["quote"]["ChangeinPercent"];
          
          	if(stockhash["Ask"].to_s != "")
          		stockhash["Ask"] = "$" + stockhash["Ask"].to_s
          	end
          
          	stockhash["changecss"] = case stockhash["Change"][0]
          		when "-" then "changeminus"
          		when "+" then "changeplus"
          		else "change"
          	end
          
          	@Stocks = stockhash;
          
          	smsnumber = String.new;
          	smsnumber = params[:SMSnumber]
          
          	if(smsnumber =~ /^\+[1-9]{1}[0-9]{7,11}$/)  	
          		message = stockhash["Name"] + " (" + stockhash["Symbol"] + ") " + stockhash["Ask"]
          	
          		smshash = Hash.new;
          		smshash = sendtext(smsnumber,message)
          	
          		stockhash["sms"] = smsnumber.to_str;
          	else
          		stockhash["sms"] = ""
          	end
     end

     def home
     end
     
     def sms
	stockhash = Hash.new;
	smsnumber = String.new;
	smstext = String.new;
	smsnumber = "+" + params[:msisdn]
     	smstext = params[:text]
	smstext.upcase.gsub!(/![A-Z]/, "")

     	stocksresults = get_yql_data(smstext);
     	stockhash["Symbol"] = stocksresults["query"]["results"]["quote"]["symbol"];
        stockhash["Ask"] = stocksresults["query"]["results"]["quote"]["Ask"];
        stockhash["Name"] = stocksresults["query"]["results"]["quote"]["Name"];
        stockhash["Change"] = stocksresults["query"]["results"]["quote"]["Change"];

     	message = stockhash["Name"] + " (" + stockhash["Symbol"] + ") $" + stockhash["Ask"]
        smshash = Hash.new;
        smshash = sendtext(smsnumber,message)
     end

     def get_yql_data(ticker)
          url = "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quotes%20where%20symbol%3D%22#{ ticker }%22&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback="
          resp = Net::HTTP.get_response(URI.parse(url))
          result = JSON.parse(resp.body)
          return result
     end
     
     def sendtext(smsnumber,message)
     	smsnumber = smsnumber.gsub!(/\D/, "") 
     	message = message.gsub!(" ", "+") 
	url = "http://rest.nexmo.com/sms/json?username=65a453b0&password=00df3f70&from=46769436063&to=" + smsnumber + "&text=" + message
	resp = Net::HTTP.get_response(URI.parse(url))
	result = JSON.parse(resp.body)
     	return result
     end

end
