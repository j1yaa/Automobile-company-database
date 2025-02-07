"""Credits to this stack overflow forum: https://stackoverflow.com/questions/21903411/enable-python-to-connect-to-mysql-via-ssh-tunnelling
For Helping Me Connect My Database

Furthermore, I used primarily these two sources:https://medium.com/@joseortizcosta/search-utility-with-flask-and-mysql-60bb8ee83dad
and https://www.youtube.com/watch?v=PWEl1ysbPAY&t=1s

These two sources acted as the skeleton for my code, which I proceeded to alter until I got it working the way I wanted it to"""

from flask import Flask, render_template, request, g, redirect
from sshtunnel import SSHTunnelForwarder
import mysql.connector
#initializng flask app
app = Flask(__name__)

# Connection Variables
ssh_hostname = "celldb-cse.eng.unt.edu"
ssh_username = "cjp0242"
ssh_password = "March2003$"
db_hostname = "localhost"
db_username = "cjp0242"
db_password = "11492139"
db_name = "csce4350_248_team1_proj"
db_port = 3306

#opening and closing of DB connection upon every request
@app.before_request
def before_request():
    #this involves the SSH tunnel we have to go through in order to connect to the db
    #essentially, if g, our global variable for connections, does not currently have a tunnel connection, then it will attempt to make a connection upon request
    if not hasattr(g, 'tunnel') or not g.tunnel.is_active:
        g.tunnel = SSHTunnelForwarder(
            (ssh_hostname, 22),
            ssh_username=ssh_username,
            ssh_password=ssh_password,
            remote_bind_address=(db_hostname, db_port)
        )
        g.tunnel.start()
       #similar to the above lines of code, this just applies to the actual database connection after the tunnel is established 
    if not hasattr(g, 'db') or g.db is None:
        g.db = mysql.connector.connect(
            host="127.0.0.1",
            port=g.tunnel.local_bind_port,
            user=db_username,
            password=db_password,
            database=db_name
        )

#this will then close the connections after they have been used by the request the connection was called by
@app.teardown_request
def teardown_request(exception=None):
    if hasattr(g, 'db') and g.db.is_connected():
        g.db.close()
    if hasattr(g, 'tunnel') and g.tunnel.is_active:
        g.tunnel.stop()

print("Welcome To The Interface Selection Program! Head To Your Local Host To Test Out Client GUI's")
print("It Is Recommended To Rerun This Program Every Time You Would Like To Switch Clients")

#Selection Homepage, this just acts as the client options screem
@app.route('/')
def home():
    return render_template('selection.html')

# Dealer Vehicle Locator Search
#This is the first of three routes which lead to separate pages, the program executes queries and presents the returned results in a more presentable way for each client
@app.route('/dealer', methods=['GET', 'POST'])
def dealer():
    if request.method == "POST":
        #this saves our user search input, used in the query comparison
        model = request.form['q']
        #the cursor selects the results from the connected database
        cursor = g.db.cursor()
        #this query structure, provided primarily by one of the links above, works to compare keywords used in the search bar to the queried elements, creating a functional search bar
        cursor.execute("""SELECT Vehicle.ModelId, Vehicle.BrandID, Vehicle.Color, Vehicle.VIN, DealerInventory.VehicleStatus, Dealer.Name, Dealer.Address1, Dealer.City, Dealer.State FROM Vehicle 
                       INNER JOIN DealerInventory ON Vehicle.VIN=DealerInventory.VIN 
                       INNER JOIN Dealer ON DealerInventory.DealerId=Dealer.DealerID 
                       WHERE ModelId LIKE %s OR BrandID LIKE %s""" , (model, model))
        #this catches all results from the cursor for display
        data = cursor.fetchall()
        #this is another portion primarily provided by one of the sources above, but it allows us to type in 'all' to display every option the database search provides, essentially just a select * query
        if len(data) == 0 and model == 'all':
            cursor.execute("""SELECT Vehicle.ModelId, Vehicle.BrandID, Vehicle.Color, Vehicle.VIN, DealerInventory.VehicleStatus, Dealer.Name, Dealer.Address1, Dealer.City, Dealer.State FROM Vehicle
                        INNER JOIN DealerInventory ON Vehicle.VIN=DealerInventory.VIN 
                        INNER JOIN Dealer ON DealerInventory.DealerId=Dealer.DealerId""")
            data = cursor.fetchall()
        cursor.close()
        #this sends all of our query results to be display at our html pages thanks to flask's functionalities provided by jinja 
        return render_template('dealer.html', data=data)
    return render_template('dealer.html')

# Customer Search
#This is just the client search with some slightly different sections based on the project guidelines so I won't go too in depth
@app.route('/customer', methods=['GET', 'POST'])
def customer():
    if request.method == "POST":
        model = request.form['q']
        cursor = g.db.cursor()
        cursor.execute("""SELECT Vehicle.ModelId, Vehicle.BrandID, Vehicle.Color, Vehicle.VIN, SalesVehicle.Price, Dealer.Name, Dealer.Address1, Dealer.City, Dealer.State FROM Vehicle 
                       INNER JOIN DealerInventory ON Vehicle.VIN=DealerInventory.VIN 
                       INNER JOIN SalesVehicle ON Vehicle.VIN=SalesVehicle.VIN 
                       INNER JOIN Dealer ON DealerInventory.DealerId=Dealer.DealerID 
                       WHERE (ModelId LIKE %s OR BrandID LIKE %s)
                       AND DealerInventory.VehicleStatus = 'I' """ , (model, model))
        data = cursor.fetchall()
        if len(data) == 0 and model == 'all':
            cursor.execute("""SELECT Vehicle.ModelId, Vehicle.BrandID, Vehicle.Color, Vehicle.VIN,  SalesVehicle.Price, Dealer.Name, Dealer.Address1, Dealer.City, Dealer.State FROM Vehicle
                        INNER JOIN DealerInventory ON Vehicle.VIN=DealerInventory.VIN 
                        INNER JOIN SalesVehicle ON Vehicle.VIN=SalesVehicle.VIN 
                        INNER JOIN Dealer ON DealerInventory.DealerId=Dealer.DealerId
                        WHERE DealerInventory.VehicleStatus = 'I'""")
            data = cursor.fetchall()
        cursor.close()
        return render_template('customer.html', data=data)
    return render_template('customer.html')

# Sales Report Generation
#This is a bit different than the other two clients. I made the decision to make queries more predetermined with slightly different formatting
@app.route('/sales', methods=['GET', 'POST'])
def sales():
    if request.method == "POST":
        #instead of something that saves user input, this is a dictionary that saves the numerous queries in this route
        results={}
        cursor = g.db.cursor()
        #2027 Profit Query
        cursor.execute("""SELECT SUM(GrandTotal) FROM Sales 
                       WHERE SaleDate LIKE '2027%' """) 
        #the or [0] statement allowed me to check for errors without the entire website crashing
        results['2027p']= cursor.fetchone() or [0]

        #Previous Years Profit Query
        cursor.execute("""SELECT SUM(GrandTotal) FROM Sales 
                       WHERE SaleDate LIKE '2026%'""")
        results['2026p']= cursor.fetchone() or [0]

        cursor.execute("""SELECT SUM(GrandTotal) FROM Sales 
                       WHERE SaleDate LIKE '2025%'""")
        results['2025p']= cursor.fetchone() or [0]

        cursor.execute("""SELECT SUM(GrandTotal) FROM Sales 
                       WHERE SaleDate LIKE '2024%'""")
        results['2024p']= cursor.fetchone() or [0]

        cursor.execute("""SELECT SUM(GrandTotal) FROM Sales 
                       WHERE SaleDate LIKE '2023%'""")
        results['2023p']= cursor.fetchone() or [0]

        cursor.execute("""SELECT SUM(GrandTotal) FROM Sales 
                       WHERE SaleDate LIKE '2022%'""")
        results['2022p']= cursor.fetchone() or [0]

        #Total OVA Profit Query
        cursor.execute("""SELECT SUM(GrandTotal) FROM Sales""")
        results['ova']= cursor.fetchone() or [0]

        #Average Yearly Profit Query
        cursor.execute("""SELECT SUM(GrandTotal)/6 FROM Sales""")
        results['avg']= cursor.fetchone() or [0]

        #Individual Contributions
        cursor.execute("""SELECT DealerId, SUM(GrandTotal) AS contribution FROM Sales
                       GROUP BY DealerId
                       ORDER BY contribution desc""")
        results['dealers']= cursor.fetchall() or [0]

        #Overall Best-Selling Brand
        cursor.execute("""SELECT Vehicle.BrandID, SUM(Total) AS max FROM SalesVehicle
                       INNER JOIN Vehicle ON SalesVehicle.VIN=Vehicle.VIN
                       GROUP BY Vehicle.BrandID
                       ORDER BY max desc
                       LIMIT 1""")
        results['bbrand']= cursor.fetchall() or [0]
        #this portion of the dictionary liked to show additional text describing the number value as 'DECIMAL', this converts the total value to float so the addtional text is not presented, this applies to the next three queries
        results['bbrand'] = [(brand, float(brandTotal)) for brand, brandTotal in results.get('bbrand', [(0, 0)])]

        #Overall Best-Selling Color
        cursor.execute("""SELECT Vehicle.Color, SUM(Total) AS max FROM SalesVehicle
                       INNER JOIN Vehicle ON SalesVehicle.VIN=Vehicle.VIN
                       GROUP BY Vehicle.Color
                       ORDER BY max desc
                       LIMIT 1""")
        results['bcolor']= cursor.fetchall() or [0]
        results['bcolor'] = [(color, float(colorTotal)) for color, colorTotal in results.get('bcolor', [(0, 0)])]

        #Overall Best-Selling Part
        cursor.execute("""SELECT Parts.Name, SUM(Total) AS max FROM SalesPart
                       INNER JOIN PartsInventory ON SalesPart.PartInventoryID=PartsInventory.PartInventoryId
                       INNER JOIN Parts ON PartsInventory.PartNumber=Parts.PartNumber
                       GROUP BY Parts.Name
                       ORDER BY max desc
                       LIMIT 1""")
        results['bpart']= cursor.fetchall() or [0]
        results['bpart'] = [(part, float(partTotal)) for part,partTotal in results.get('bpart', [(0, 0)])]
        cursor.close()
        return render_template('sales.html', results=results)
    return render_template('sales.html', results={})
#runs the app
if __name__ == '__main__':
    app.run(debug=True)

    '''I chose to leave the html files uncommeneted as their formats are already complex as it is.
    Most comments would be redundant and just take up space. The only main notes I would say about them is they
    are heavily based from skeletons of my two sources, alot of it is just tables and tedious for loops used for jinja processing
    '''