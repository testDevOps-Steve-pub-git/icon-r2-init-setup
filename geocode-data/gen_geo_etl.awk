# Prelude
BEGIN {
	printf ("COPY geocode (postal_code, city, province_abbr, province, street_name, \
		street_type, street_type_full, street_dir, street_dir_full, street_from_no, street_to_no, \
		rural_route, country) FROM stdin;\n")
}

# Process input stream
{
	main()
}

# Prologue
END {
	printf ("\\.\n")
}

function main () {
	# Extract common fields from record
	REC_TYPE = substr($0, 1, 1)
	ADDR_TYPE = substr($0, 2, 1)
	PROV_ABBR = substr($0, 3, 2)
	ST_NAME = substr($0, 35, 30)
	ST_TYPE = substr($0, 65, 6)
	ST_DIR = "\\N"
	ST_NUM_TO = substr($0, 74, 6)
	ST_NUM_FROM = substr($0, 100, 6)
	MUN = substr($0, 113, 30)
	POSTAL = substr($0, 168, 6)
	ACTION = substr($0, 180, 1)
	ROUTE = "\\N"
	COUNTRY = "CANADA"

	# Skip records which are deleted or postal station
	if (ACTION == "D" || REC_TYPE == "5") {
		return;
	}

	# Extract address record
	if (REC_TYPE == "1") {
		ST_DIR = substr($0, 71, 2)
	}

	# Extract route and GD record
	else if (REC_TYPE == "2") {
		ST_DIR = substr($0, 71, 2)
		ROUTE=substr($0, 144, 6)
	}

	# Extract lock box record
	else if (REC_TYPE == "3") {
		ST_NUM_TO=substr($0, 85, 5)
		ST_NUM_FROM=substr($0,1 50, 5)
	}

	# Extrct route record
	else if (REC_TYPE == "4") {
		ROUTE=substr($0, 85, 6)
	}

	# Remove padding (+$/ = right trim, */ = all spaces)
	gsub(/[[:space:]]+$/, "", PROV_ABBR)
	gsub(/[[:space:]]+$/, "", ST_NAME)
	gsub(/[[:space:]]*/, "", ST_TYPE)
	gsub(/[[:space:]]*/, "", ST_DIR)
	gsub(/[[:space:]]+$/, "", ST_NUM_TO)
	gsub(/[[:space:]]+$/, "", ST_NUM_FROM)
	gsub(/[[:space:]]+$/, "", MUN)
	gsub(/[[:space:]]+$/, "", ROUTE)
	gsub(/[[:space:]]*/, "", POSTAL)

	# Remove non-numeric street numbers
	if (ST_NUM_FROM !~ /^[0-9]+$/)
		ST_NUM_FROM = "\\N"
	if (ST_NUM_TO !~ /^[0-9]+$/)
		ST_NUM_TO = "\\N"

	# Interpolate full descriptions
	PROV_FULL = getFullProv(PROV_ABBR)
	ST_TYPE_FULL = getFullStreetType(ST_TYPE)
	ST_DIR_FULL = getFullStreetDir(PROV_ABBR, ST_DIR)

	# Replace empty with null
	if (ST_TYPE == "")
		ST_TYPE = "\\N"
	if (ST_DIR == "")
		ST_DIR = "\\N"
	if (ST_NUM_FROM == "")
		ST_NUM_FROM = "\\N"
	if (ST_NUM_TO == "")
		ST_NUM_TO = "\\N"
	if (ROUTE == "")
		ROUTE = "\\N"

	# Write records
	printf ("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", \
		POSTAL, MUN, PROV_ABBR, PROV_FULL, ST_NAME, \
		ST_TYPE, ST_TYPE_FULL, ST_DIR, ST_DIR_FULL, ST_NUM_FROM, ST_NUM_TO, \
		ROUTE, COUNTRY)
}

function getFullProv (PROV_ABBR) {
	PROV_FULL = "\\N"
	if (PROV_ABBR == "")
		PROV_FULL = "\\N"
	else if (PROV_ABBR == "NL")
		PROV_FULL = "NEWFOUNDLAND AND LABRADOR"
	else if (PROV_ABBR == "NS")
		PROV_FULL = "NOVA SCOTIA"
	else if (PROV_ABBR == "PE")
		PROV_FULL = "PRINCE EDWARD ISLAND"
	else if (PROV_ABBR == "NB")
		PROV_FULL = "NEW BRUNSWICK"
	else if (PROV_ABBR == "QC")
		PROV_FULL = "QUEBEC"
	else if (PROV_ABBR == "ON")
		PROV_FULL = "ONTARIO"
	else if (PROV_ABBR == "MB")
		PROV_FULL = "MANITOBA"
	else if (PROV_ABBR == "SK")
		PROV_FULL = "SASKATCHEWAN"
	else if (PROV_ABBR == "AB")
		PROV_FULL = "ALBERTA"
	else if (PROV_ABBR == "BC")
		PROV_FULL = "BRITISH COLUMBIA"
	else if (PROV_ABBR == "NT")
		PROV_FULL = "NORTHWEST TERRITORIES"
	else if (PROV_ABBR == "YT")
		PROV_FULL = "YUKON"
	else if (PROV_ABBR == "NU")
		PROV_FULL = "NUNAVUT"
	return PROV_FULL	
}

function getFullStreetType (ST_TYPE) {
	ST_TYPE_FULL = "\\N"
	if (ST_TYPE == "")
		ST_TYPE_FULL = "\\N"

	# A
	else if (ST_TYPE == "ABBEY")
		ST_TYPE_FULL = "Abbey"
	else if (ST_TYPE == "ACRES")
		ST_TYPE_FULL = "Acres"
	else if (ST_TYPE == "ALLEE")
		ST_TYPE_FULL = "Allée"				
	else if (ST_TYPE == "ALLÉE")
		ST_TYPE_FULL = "Allée"
	else if (ST_TYPE == "ALLEY")
		ST_TYPE_FULL = "Alley"
	else if (ST_TYPE == "AUT")
		ST_TYPE_FULL = "Autoroute"
	else if (ST_TYPE == "AV")
		ST_TYPE_FULL = "Avenue"
	else if (ST_TYPE == "AVE")
		ST_TYPE_FULL = "Avenue"

	# B		
	else if (ST_TYPE == "BAY")
		ST_TYPE_FULL = "Bay"
	else if (ST_TYPE == "BEACH")
		ST_TYPE_FULL = "Beach"
	else if (ST_TYPE == "BEND")
		ST_TYPE_FULL = "Bend"
	else if (ST_TYPE == "BLVD")
		ST_TYPE_FULL = "Boulevard"
	else if (ST_TYPE == "BOUL")
		ST_TYPE_FULL = "Boulevard"
	else if (ST_TYPE == "BYPASS")
		ST_TYPE_FULL = "By-pass"
	else if (ST_TYPE == "BYWAY")
		ST_TYPE_FULL = "Byway"

	# C		
	else if (ST_TYPE == "C")
		ST_TYPE_FULL = "Centre"
	else if (ST_TYPE == "CAMPUS")
		ST_TYPE_FULL = "Campus"
	else if (ST_TYPE == "CAPE")
		ST_TYPE_FULL = "Cape"
	else if (ST_TYPE == "CAR")
		ST_TYPE_FULL = "Carré"
	else if (ST_TYPE == "CARREF")
		ST_TYPE_FULL = "Carrefour"
	else if (ST_TYPE == "CDS")
		ST_TYPE_FULL = "Cul-de-sac"
	else if (ST_TYPE == "CERCLE")
		ST_TYPE_FULL = "Cercle"
	else if (ST_TYPE == "CH")
		ST_TYPE_FULL = "Chemin"
	else if (ST_TYPE == "CHASE")
		ST_TYPE_FULL = "Chase"
	else if (ST_TYPE == "CIR")
		ST_TYPE_FULL = "Circle"
	else if (ST_TYPE == "CIRCT")
		ST_TYPE_FULL = "Circuit"
	else if (ST_TYPE == "CLOSE")
		ST_TYPE_FULL = "Close"
	else if (ST_TYPE == "COMMON")
		ST_TYPE_FULL = "Common"
	else if (ST_TYPE == "CONC")
		ST_TYPE_FULL = "Concession"
	else if (ST_TYPE == "CÔTE")
		ST_TYPE_FULL = "Côte"
	else if (ST_TYPE == "COTE")
		ST_TYPE_FULL = "Côte"
	else if (ST_TYPE == "COUR")
		ST_TYPE_FULL = "Cour"
	else if (ST_TYPE == "COURS")
		ST_TYPE_FULL = "Cours"
	else if (ST_TYPE == "COVE")
		ST_TYPE_FULL = "Cove"
	else if (ST_TYPE == "CRNRS")
		ST_TYPE_FULL = "Corners"
	else if (ST_TYPE == "CRES")
		ST_TYPE_FULL = "Crescent"
	else if (ST_TYPE == "CROIS")
		ST_TYPE_FULL = "Croissant"
	else if (ST_TYPE == "CROSS")
		ST_TYPE_FULL = "Crossing"
	else if (ST_TYPE == "CRT")
		ST_TYPE_FULL = "Court"
	else if (ST_TYPE == "CTR")
		ST_TYPE_FULL = "Centre"

	# D		
	else if (ST_TYPE == "DALE")
		ST_TYPE_FULL = "Dale"
	else if (ST_TYPE == "DELL")
		ST_TYPE_FULL = "Dell"
	else if (ST_TYPE == "DIVERS")
		ST_TYPE_FULL = "Diversion"
	else if (ST_TYPE == "DOWNS")
		ST_TYPE_FULL = "Downs"
	else if (ST_TYPE == "DR")
		ST_TYPE_FULL = "Drive"
	
	# E
	else if (ST_TYPE == "ÉCH")
		ST_TYPE_FULL = "Échangeur"
	else if (ST_TYPE == "END")
		ST_TYPE_FULL = "End"
	else if (ST_TYPE == "ESPL")
		ST_TYPE_FULL = "Esplanade"
	else if (ST_TYPE == "ESTATE")
		ST_TYPE_FULL = "Estates"
	else if (ST_TYPE == "EXPY")
		ST_TYPE_FULL = "Expressway"
	else if (ST_TYPE == "EXTEN")
		ST_TYPE_FULL = "Extension"

	# F		
	else if (ST_TYPE == "FARM")
		ST_TYPE_FULL = "Farm"
	else if (ST_TYPE == "FIELD")
		ST_TYPE_FULL = "Field"
	else if (ST_TYPE == "FOREST")
		ST_TYPE_FULL = "Forest"
	else if (ST_TYPE == "FRONT")
		ST_TYPE_FULL = "Front"
	else if (ST_TYPE == "FWY")
		ST_TYPE_FULL = "Freeway"

	# G		
	else if (ST_TYPE == "GATE")
		ST_TYPE_FULL = "Gate"
	else if (ST_TYPE == "GDNS")
		ST_TYPE_FULL = "Gardens"
	else if (ST_TYPE == "GLADE")
		ST_TYPE_FULL = "Glade"
	else if (ST_TYPE == "GLEN")
		ST_TYPE_FULL = "Glen"
	else if (ST_TYPE == "GREEN")
		ST_TYPE_FULL = "Green"
	else if (ST_TYPE == "GRNDS")
		ST_TYPE_FULL = "Grounds"
	else if (ST_TYPE == "GROVE")
		ST_TYPE_FULL = "Grove"
	
	# H
	else if (ST_TYPE == "HARBR")
		ST_TYPE_FULL = "Harbour"
	else if (ST_TYPE == "HEATH")
		ST_TYPE_FULL = "Heath"
	else if (ST_TYPE == "HTS")
		ST_TYPE_FULL = "Heights"
	else if (ST_TYPE == "HGHLDS")
		ST_TYPE_FULL = "Highlands"
	else if (ST_TYPE == "HILL")
		ST_TYPE_FULL = "Hill"
	else if (ST_TYPE == "HOLLOW")
		ST_TYPE_FULL = "Hollow"
	else if (ST_TYPE == "HWY")
		ST_TYPE_FULL = "Highway"
	
	# I
	else if (ST_TYPE == "ÎLE")
		ST_TYPE_FULL = "Île"
	else if (ST_TYPE == "ILE")
		ST_TYPE_FULL = "Île"	
	else if (ST_TYPE == "IMP")
		ST_TYPE_FULL = "Impasse"
	else if (ST_TYPE == "INLET")
		ST_TYPE_FULL = "Inlet"
	else if (ST_TYPE == "ISLAND")
		ST_TYPE_FULL = "Island"
		
	# J
	# K	
	else if (ST_TYPE == "KEY")
		ST_TYPE_FULL = "Key"
	else if (ST_TYPE == "KNOLL")
		ST_TYPE_FULL = "Knoll"

	# L	
	else if (ST_TYPE == "LANDNG")
		ST_TYPE_FULL = "Landing"
	else if (ST_TYPE == "LANE")
		ST_TYPE_FULL = "Lane"
	else if (ST_TYPE == "LINE")
		ST_TYPE_FULL = "Line"
	else if (ST_TYPE == "LINK")
		ST_TYPE_FULL = "Link"
	else if (ST_TYPE == "LKOUT")
		ST_TYPE_FULL = "Lookout"
	else if (ST_TYPE == "LMTS")
		ST_TYPE_FULL = "Limits"
	else if (ST_TYPE == "LOOP")
		ST_TYPE_FULL = "Loop"

	# M		
	else if (ST_TYPE == "MALL")
		ST_TYPE_FULL = "Mall"
	else if (ST_TYPE == "MANOR")
		ST_TYPE_FULL = "Manor"
	else if (ST_TYPE == "MAZE")
		ST_TYPE_FULL = "Maze"
	else if (ST_TYPE == "MEADOW")
		ST_TYPE_FULL = "Meadow"
	else if (ST_TYPE == "MEWS")
		ST_TYPE_FULL = "Mews"
	else if (ST_TYPE == "MONTÉE")
		ST_TYPE_FULL = "Montée"
	else if (ST_TYPE == "MONTEE")
		ST_TYPE_FULL = "Montée"
	else if (ST_TYPE == "MOOR")
		ST_TYPE_FULL = "Moor"
	else if (ST_TYPE == "MOUNT")
		ST_TYPE_FULL = "Mount"
	else if (ST_TYPE == "MTN")
		ST_TYPE_FULL = "Mountain"
		
	# N
	# O
	else if (ST_TYPE == "ORCH")
		ST_TYPE_FULL = "Orchard"

	# P
	else if (ST_TYPE == "PARADE")
		ST_TYPE_FULL = "Parade"
	else if (ST_TYPE == "PARC")
		ST_TYPE_FULL = "Parc"
	else if (ST_TYPE == "PASS")
		ST_TYPE_FULL = "Passage"
	else if (ST_TYPE == "PATH")
		ST_TYPE_FULL = "Path"
	else if (ST_TYPE == "PINES")
		ST_TYPE_FULL = "Pines"
	else if (ST_TYPE == "PK")
		ST_TYPE_FULL = "Park"
	else if (ST_TYPE == "PKY")
		ST_TYPE_FULL = "Parkway"
	else if (ST_TYPE == "PL")
		ST_TYPE_FULL = "Place"
	else if (ST_TYPE == "PLACE")
		ST_TYPE_FULL = "Place"
	else if (ST_TYPE == "PLAT")
		ST_TYPE_FULL = "Plateau"
	else if (ST_TYPE == "PLAZA")
		ST_TYPE_FULL = "Plaza"
	else if (ST_TYPE == "POINTE")
		ST_TYPE_FULL = "Pointe"
	else if (ST_TYPE == "PORT")
		ST_TYPE_FULL = "Port"
	else if (ST_TYPE == "PROM")
		ST_TYPE_FULL = "Promenade"
	else if (ST_TYPE == "PT")
		ST_TYPE_FULL = "Point"
	else if (ST_TYPE == "PTWAY")
		ST_TYPE_FULL = "Pathway"
	else if (ST_TYPE == "PVT")
		ST_TYPE_FULL = "Private"

	# Q	
	else if (ST_TYPE == "QUAI")
		ST_TYPE_FULL = "Quai"
	else if (ST_TYPE == "QUAY")
		ST_TYPE_FULL = "Quay"
		
	# R
	else if (ST_TYPE == "RAMP")
		ST_TYPE_FULL = "Ramp"
	else if (ST_TYPE == "RANG")
		ST_TYPE_FULL = "Rang"
	else if (ST_TYPE == "RD")
		ST_TYPE_FULL = "Road"
	else if (ST_TYPE == "RDPT")
		ST_TYPE_FULL = "Rond-point"
	else if (ST_TYPE == "RG")
		ST_TYPE_FULL = "Range"
	else if (ST_TYPE == "RIDGE")
		ST_TYPE_FULL = "Ridge"
	else if (ST_TYPE == "RISE")
		ST_TYPE_FULL = "Rise"
	else if (ST_TYPE == "RLE")
		ST_TYPE_FULL = "Ruelle"
	else if (ST_TYPE == "ROW")
		ST_TYPE_FULL = "Row"
	else if (ST_TYPE == "RTE")
		ST_TYPE_FULL = "Route"
	else if (ST_TYPE == "RUE")
		ST_TYPE_FULL = "Rue"
	else if (ST_TYPE == "RUN")
		ST_TYPE_FULL = "Run"

	# S		
	else if (ST_TYPE == "SENT")
		ST_TYPE_FULL = "Sentier"
	else if (ST_TYPE == "SQ")
		ST_TYPE_FULL = "Square"
	else if (ST_TYPE == "ST")
		ST_TYPE_FULL = "Street"
	else if (ST_TYPE == "SUBDIV")
		ST_TYPE_FULL = "Subdivision"

	# T		
	else if (ST_TYPE == "TERR")
		ST_TYPE_FULL = "Terrace"
	else if (ST_TYPE == "THICK")
		ST_TYPE_FULL = "Thicket"
	else if (ST_TYPE == "TLINE")
		ST_TYPE_FULL = "Townline"
	else if (ST_TYPE == "TOWERS")
		ST_TYPE_FULL = "Towers"
	else if (ST_TYPE == "TRAIL")
		ST_TYPE_FULL = "Trail"
	else if (ST_TYPE == "TRNABT")
		ST_TYPE_FULL = "Turnabout"
	else if (ST_TYPE == "TSSE")
		ST_TYPE_FULL = "Terrasse"
	
	# U
	# V
	else if (ST_TYPE == "VALE")
		ST_TYPE_FULL = "Vale"
	else if (ST_TYPE == "VIA")
		ST_TYPE_FULL = "Via"
	else if (ST_TYPE == "VIEW")
		ST_TYPE_FULL = "View"
	else if (ST_TYPE == "VILLAS")
		ST_TYPE_FULL = "Villas"
	else if (ST_TYPE == "VILLGE")
		ST_TYPE_FULL = "Village"
	else if (ST_TYPE == "VISTA")
		ST_TYPE_FULL = "Vista"
	else if (ST_TYPE == "VOIE")
		ST_TYPE_FULL = "Voie"
	
	# W
	else if (ST_TYPE == "WALK")
		ST_TYPE_FULL = "Walk"
	else if (ST_TYPE == "WAY")
		ST_TYPE_FULL = "Way"
	else if (ST_TYPE == "WHARF")
		ST_TYPE_FULL = "Wharf"
	else if (ST_TYPE == "WOOD")
		ST_TYPE_FULL = "Wood"
	else if (ST_TYPE == "WYND")
		ST_TYPE_FULL = "Wynd"
	
	# X
	# Y
	# Z	

	return ST_TYPE_FULL
}

function getFullStreetDir (PROV_ABBR, ST_DIR) {
	ST_DIR_FULL = "\\N"
	if (PROV_ABBR == "QC") {
		if (ST_DIR == "N")
			ST_DIR_FULL = "Nord"
		else if (ST_DIR == "NE")
			ST_DIR_FULL = "Nord-Est"
		else if (ST_DIR == "E")
			ST_DIR_FULL = "Est"
		else if (ST_DIR == "SE")
			ST_DIR_FULL = "Sud-Est"
		else if (ST_DIR == "S")
			ST_DIR_FULL = "Sud"
		else if (ST_DIR == "SW" || ST_DIR == "SO") {
		    ST_DIR = "SO"
			ST_DIR_FULL = "Sud-Ouest"
		}
		else if (ST_DIR == "W" || ST_DIR == "O") {
			ST_DIR = "O"
			ST_DIR_FULL = "Ouest"
		}
		else if (ST_DIR == "NW" || ST_DIR == "NO") {
			ST_DIR = "NO"
			ST_DIR_FULL = "Nord-Ouest"
		}
	}
	else {
		if (ST_DIR == "N")
			ST_DIR_FULL = "North"
		else if (ST_DIR == "NE")
			ST_DIR_FULL = "Northeast"
		else if (ST_DIR == "E")
			ST_DIR_FULL = "East"
		else if (ST_DIR == "SE")
			ST_DIR_FULL = "Southeast";
		else if (ST_DIR == "S")
			ST_DIR_FULL = "South"
		else if (ST_DIR == "SW" || ST_DIR == "SO") {
			ST_DIR = "SW"
			ST_DIR_FULL = "Southwest"
		}
		else if (ST_DIR == "W" || ST_DIR == "O") {
			ST_DIR = "W"
			ST_DIR_FULL = "West"
		}
		else if (ST_DIR == "NW" || ST_DIR == "NO") {
			ST_DIR = "NW"
			ST_DIR_FULL = "Northwest"
		}
	}
	return ST_DIR_FULL
}
