require "odbc"
require 'sinatra'

set :port, 8080

DSN  = "hana"
USER = "SYSTEM"
PWD  = "bemT4amt"

$queryResult = [""]
$userQuery = ""

def fetchRows statement
  res = []
  while row = statement.fetch
    res.push row
  end
  res
end

def processSQL query
  puts "Query '#{query}' received"
  begin
    statement = $dbh.prepare query
    $userQuery = query
    statement.execute
    msg = fetchRows statement
    $queryResult = msg
    statement.drop
  rescue Exception => e
    puts e.message
  end

  msg
end

get '/' do
  begin
    $dbh = ODBC.connect(DSN, USER, PWD)
  rescue Exception => e
    return "Error happend connecting ODBC data source: " + e.to_s
  end
  # params[:result] = $queryResult
  @result = $queryResult

  erb :index
end

post '/submit' do
  msg = processSQL(params[:query])
  redirect "/"
end

