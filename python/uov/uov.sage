###################################################
#      Functions for Unbalance Oil Vinegar        #
#                                                 #
#   Jose Luis Juan Herrera Garcia    August, 2015 #
#   Thesis work                                   #
#   Computer science graduate studies             #
###################################################

###################################################
#                      Add-on's                   #
###################################################
import copy

###################################################
#                    Functions                    #
###################################################
def genQuadTerm(idx1, idx2, x):
    gamma = ZZ.random_element(2) # gamma = 0 or 1
    return gamma * x[idx1] * x[idx2]

def genLinTerm(idx, x):
    beta = ZZ.random_element(2) # beta = 0 or 1
    return beta * x[idx]

def genConstTerm():
    return ZZ.random_element(2) # return 0 or 1

def genPolyVectorUOV(o, v, x, Pi, Debug = False):
    ''' Randomly generates 'o' polynomials in 'o' + 'v' variables
        with coefficients in GF(2). Polynomial vector in Pi
        Remark: x(0) to x(v-1) are vinegar variables; x(v) to
        x(n-1) are oil variables '''
    n = o + v
    for i in range(o):  # 'i' represents the polynomial number to generate
        if ( Debug == True ):
            print "{0} ".format(i+1),
            sys.stdout.flush()
        Pi[i] = 0
        for j in range(v):
            for k in range(j+1, n):
                Pi[i] += genQuadTerm(j, k, x)
        for j in range(n):
            Pi[i] += genLinTerm(j, x)
        Pi[i] += genConstTerm()
    print

def genVinegarVals(Vvals):
    ''' Generate 'len(Vvals)' random bits, corresponding to the vinegar values
        giving back the result in predefined vector 'Vvals' '''
    for i in range( len(Vvals) ):
        Vvals[i] = ZZ.random_element(2)

def printPolyVect(Pi, Msg=""):
    ''' Print each polynomial in the polynomial vector 'Pi' '''
    print Msg
    for i in range( len(Pi) ):
        print '{}. {}'.format(i+1, Pi[i])

def onlyOilPolyVect(Vvals, PolyVect, x):
    ''' Substitute vinegar values (Vvals) in given polynomial vector
        (PolyVect), modifying 'PolyVect' to have only 'Oil' variables '''
    for i in range( len(PolyVect) ):
        for j in range( len(Vvals) ):
            PolyVect[i] = PolyVect[i].subs( {x[j]:Vvals[j]} )

def eval1(Poly, x, assig, start):
    ''' Evaluates a polynomial "Poly" in 1 variable,
        starting with the variable "start" and taking values from
        "assig". '''
    Poly = Poly.subs( {x[start]:assig[start]} )
    return Poly

def eval2(Poly, x, assig, start):
    ''' Evaluates a polynomial "Poly" in 2 variables in parallel,
        starting with the variable "start" and taking values from
        "assig". '''
    Poly = Poly.subs( {x[start]:assig[start], x[start+1]:assig[start+1]} )
    return Poly

def eval4(Poly, x, assig, start):
    ''' Evaluates a polynomial "Poly" in 4 variables in parallel,
        starting with the variable "start" and taking values from
        "assig". '''
    Poly = Poly.subs( {x[start  ]:assig[start  ], x[start+1]:assig[start+1],\
                       x[start+2]:assig[start+2], x[start+3]:assig[start+3]} )
    return Poly

def eval8(Poly, x, assig, start):
    ''' Evaluates a polynomial "Poly" in 8 variables in parallel,
        starting with the variable "start" and taking values from
        "assig". '''
    Poly = Poly.subs( {x[start  ]:assig[start  ], x[start+1]:assig[start+1],\
                       x[start+2]:assig[start+2], x[start+3]:assig[start+3],\
                       x[start+4]:assig[start+4], x[start+5]:assig[start+5],\
                       x[start+6]:assig[start+6], x[start+7]:assig[start+7]} )
    return Poly

def eval16(Poly, x, assig, start):
    ''' Evaluates a polynomial "Poly" in 16 variables in parallel,
        starting with the variable "start" and taking values from
        "assig". '''
    Poly = Poly.subs( {x[start  ]:assig[start  ], x[start+1]:assig[start+1],\
                       x[start+2]:assig[start+2], x[start+3]:assig[start+3],\
                       x[start+4]:assig[start+4], x[start+5]:assig[start+5],\
                       x[start+6]:assig[start+6], x[start+7]:assig[start+7],\

                       x[start+8]:assig[start+8], x[start+9]:assig[start+9],\
                       x[start+10]:assig[start+10], x[start+11]:assig[start+11],\
                       x[start+12]:assig[start+12], x[start+13]:assig[start+13],\
                       x[start+14]:assig[start+14], x[start+15]:assig[start+15]} )
    return Poly

def eval32(Poly, x, assig, start):
    ''' Evaluates a polynomial "Poly" in 32 variables in parallel,
        starting with the variable "start" and taking values from
        "assig". '''
    Poly = Poly.subs( {x[start  ]:assig[start  ], x[start+1]:assig[start+1],\
                       x[start+2]:assig[start+2], x[start+3]:assig[start+3],\
                       x[start+4]:assig[start+4], x[start+5]:assig[start+5],\
                       x[start+6]:assig[start+6], x[start+7]:assig[start+7],\

                       x[start+8]:assig[start+8], x[start+9]:assig[start+9],\
                       x[start+10]:assig[start+10], x[start+11]:assig[start+11],\
                       x[start+12]:assig[start+12], x[start+13]:assig[start+13],\
                       x[start+14]:assig[start+14], x[start+15]:assig[start+15],\

                       x[start+16]:assig[start+16], x[start+17]:assig[start+17],\
                       x[start+18]:assig[start+18], x[start+19]:assig[start+19],\
                       x[start+20]:assig[start+20], x[start+21]:assig[start+21],\
                       x[start+22]:assig[start+22], x[start+23]:assig[start+23],\

                       x[start+24]:assig[start+24], x[start+25]:assig[start+25],\
                       x[start+26]:assig[start+26], x[start+27]:assig[start+27],\
                       x[start+28]:assig[start+28], x[start+29]:assig[start+29],\
                       x[start+30]:assig[start+30], x[start+31]:assig[start+31]} )
    return Poly

def eval64(Poly, x, assig, start):
    ''' Evaluates a polynomial "Poly" in 64 variables in parallel,
        starting with the variable "start" and taking values from
        "assig". '''
    Poly = Poly.subs( {x[start  ]:assig[start  ], x[start+1]:assig[start+1],\
                       x[start+2]:assig[start+2], x[start+3]:assig[start+3],\
                       x[start+4]:assig[start+4], x[start+5]:assig[start+5],\
                       x[start+6]:assig[start+6], x[start+7]:assig[start+7],\

                       x[start+8]:assig[start+8], x[start+9]:assig[start+9],\
                       x[start+10]:assig[start+10], x[start+11]:assig[start+11],\
                       x[start+12]:assig[start+12], x[start+13]:assig[start+13],\
                       x[start+14]:assig[start+14], x[start+15]:assig[start+15],\

                       x[start+16]:assig[start+16], x[start+17]:assig[start+17],\
                       x[start+18]:assig[start+18], x[start+19]:assig[start+19],\
                       x[start+20]:assig[start+20], x[start+21]:assig[start+21],\
                       x[start+22]:assig[start+22], x[start+23]:assig[start+23],\

                       x[start+24]:assig[start+24], x[start+25]:assig[start+25],\
                       x[start+26]:assig[start+26], x[start+27]:assig[start+27],\
                       x[start+28]:assig[start+28], x[start+29]:assig[start+29],\
                       x[start+30]:assig[start+30], x[start+31]:assig[start+31],\
                       
                       x[start+32]:assig[start+32], x[start+33]:assig[start+33],\
                       x[start+34]:assig[start+34], x[start+35]:assig[start+35],\
                       x[start+36]:assig[start+36], x[start+37]:assig[start+37],\
                       x[start+38]:assig[start+38], x[start+39]:assig[start+39],\

                       x[start+40]:assig[start+40], x[start+41]:assig[start+41],\
                       x[start+42]:assig[start+42], x[start+43]:assig[start+43],\
                       x[start+44]:assig[start+44], x[start+45]:assig[start+45],\
                       x[start+46]:assig[start+46], x[start+47]:assig[start+47],\

                       x[start+48]:assig[start+48], x[start+49]:assig[start+49],\
                       x[start+50]:assig[start+50], x[start+51]:assig[start+51],\
                       x[start+52]:assig[start+52], x[start+53]:assig[start+53],\
                       x[start+54]:assig[start+54], x[start+55]:assig[start+55],\

                       x[start+56]:assig[start+56], x[start+57]:assig[start+57],\
                       x[start+58]:assig[start+58], x[start+59]:assig[start+59],\
                       x[start+60]:assig[start+60], x[start+61]:assig[start+61],\
                       x[start+62]:assig[start+62], x[start+63]:assig[start+63]} )
    return Poly

def eval128(Poly, x, assig, start):
    ''' Evaluates a polynomial "Poly" in 128 variables in parallel,
        starting with the variable "start" and taking values from
        "assig". '''
    Poly = Poly.subs( {x[start  ]:assig[start  ], x[start+1]:assig[start+1],\
                       x[start+2]:assig[start+2], x[start+3]:assig[start+3],\
                       x[start+4]:assig[start+4], x[start+5]:assig[start+5],\
                       x[start+6]:assig[start+6], x[start+7]:assig[start+7],\

                       x[start+8]:assig[start+8], x[start+9]:assig[start+9],\
                       x[start+10]:assig[start+10], x[start+11]:assig[start+11],\
                       x[start+12]:assig[start+12], x[start+13]:assig[start+13],\
                       x[start+14]:assig[start+14], x[start+15]:assig[start+15],\

                       x[start+16]:assig[start+16], x[start+17]:assig[start+17],\
                       x[start+18]:assig[start+18], x[start+19]:assig[start+19],\
                       x[start+20]:assig[start+20], x[start+21]:assig[start+21],\
                       x[start+22]:assig[start+22], x[start+23]:assig[start+23],\

                       x[start+24]:assig[start+24], x[start+25]:assig[start+25],\
                       x[start+26]:assig[start+26], x[start+27]:assig[start+27],\
                       x[start+28]:assig[start+28], x[start+29]:assig[start+29],\
                       x[start+30]:assig[start+30], x[start+31]:assig[start+31],\
                       
                       x[start+32]:assig[start+32], x[start+33]:assig[start+33],\
                       x[start+34]:assig[start+34], x[start+35]:assig[start+35],\
                       x[start+36]:assig[start+36], x[start+37]:assig[start+37],\
                       x[start+38]:assig[start+38], x[start+39]:assig[start+39],\

                       x[start+40]:assig[start+40], x[start+41]:assig[start+41],\
                       x[start+42]:assig[start+42], x[start+43]:assig[start+43],\
                       x[start+44]:assig[start+44], x[start+45]:assig[start+45],\
                       x[start+46]:assig[start+46], x[start+47]:assig[start+47],\

                       x[start+48]:assig[start+48], x[start+49]:assig[start+49],\
                       x[start+50]:assig[start+50], x[start+51]:assig[start+51],\
                       x[start+52]:assig[start+52], x[start+53]:assig[start+53],\
                       x[start+54]:assig[start+54], x[start+55]:assig[start+55],\

                       x[start+56]:assig[start+56], x[start+57]:assig[start+57],\
                       x[start+58]:assig[start+58], x[start+59]:assig[start+59],\
                       x[start+60]:assig[start+60], x[start+61]:assig[start+61],\
                       x[start+62]:assig[start+62], x[start+63]:assig[start+63],\

                       x[start+64]:assig[start+64], x[start+65]:assig[start+65],\
                       x[start+66]:assig[start+66], x[start+67]:assig[start+67],\
                       x[start+68]:assig[start+68], x[start+69]:assig[start+69],\
                       x[start+70]:assig[start+70], x[start+71]:assig[start+71],\

                       x[start+72]:assig[start+72], x[start+73]:assig[start+73],\
                       x[start+74]:assig[start+74], x[start+75]:assig[start+75],\
                       x[start+76]:assig[start+76], x[start+77]:assig[start+77],\
                       x[start+78]:assig[start+78], x[start+79]:assig[start+79],\

                       x[start+80]:assig[start+80], x[start+81]:assig[start+81],\
                       x[start+82]:assig[start+82], x[start+83]:assig[start+83],\
                       x[start+84]:assig[start+84], x[start+85]:assig[start+85],\
                       x[start+86]:assig[start+86], x[start+87]:assig[start+87],\

                       x[start+88]:assig[start+88], x[start+89]:assig[start+89],\
                       x[start+90]:assig[start+90], x[start+91]:assig[start+91],\
                       x[start+92]:assig[start+92], x[start+93]:assig[start+93],\
                       x[start+94]:assig[start+94], x[start+95]:assig[start+95],\
                       
                       x[start+96]:assig[start+96], x[start+97]:assig[start+97],\
                       x[start+98]:assig[start+98], x[start+99]:assig[start+99],\
                       x[start+100]:assig[start+100], x[start+101]:assig[start+101],\
                       x[start+102]:assig[start+102], x[start+103]:assig[start+103],\

                       x[start+104]:assig[start+104], x[start+105]:assig[start+105],\
                       x[start+106]:assig[start+106], x[start+107]:assig[start+107],\
                       x[start+108]:assig[start+108], x[start+109]:assig[start+109],\
                       x[start+110]:assig[start+110], x[start+111]:assig[start+111],\

                       x[start+112]:assig[start+112], x[start+113]:assig[start+113],\
                       x[start+114]:assig[start+114], x[start+115]:assig[start+115],\
                       x[start+116]:assig[start+116], x[start+117]:assig[start+117],\
                       x[start+118]:assig[start+118], x[start+119]:assig[start+119],\

                       x[start+120]:assig[start+120], x[start+121]:assig[start+121],\
                       x[start+122]:assig[start+122], x[start+123]:assig[start+123],\
                       x[start+124]:assig[start+124], x[start+125]:assig[start+125],\
                       x[start+126]:assig[start+126], x[start+127]:assig[start+127]} )
    return Poly

def evalPoly(Poly, x, assig):
    ''' Substitute 'assig' values into Poly (GF(2))
        THIS FUNCTION MUST BE USED ONLY WITH
        LENGHT OF assig <= 255 !!! '''
    size  = len(assig)
    start = 0

    if ( size >= 128 ):
        remain = size % 128
        Poly   = eval128(Poly, x, assig, start)
        size   = remain
        start  += 128
        
    if ( size >= 64 ):
        remain = size % 64
        Poly   = eval64(Poly, x, assig, start)
        size   = remain
        start  += 64

    if ( size >= 32 ):
        remain = size % 32
        Poly   = eval32(Poly, x, assig, start)
        size   = remain
        start  += 32

    if ( size >= 16 ):
        remain = size % 16
        Poly   = eval16(Poly, x, assig, start)
        size   = remain
        start  += 16

    if ( size >= 8 ):
        remain = size % 8
        Poly   = eval8(Poly, x, assig, start)
        size   = remain
        start  += 8

    if ( size >= 4 ):
        remain = size % 4
        Poly   = eval4(Poly, x, assig, start)
        size   = remain
        start  += 4

    if ( size >= 2 ):
        remain = size % 2
        Poly   = eval2(Poly, x, assig, start)
        size   = remain
        start  += 2

    if ( size >= 1 ):
        Poly   = eval1(Poly, x, assig, start)
    
    return Poly

def evalPolyVect(PolyVect, x, assig, y, Debug = False):
    ''' Evaluates a polynomial vector in assignment and returns a
        vector (y) with results '''
    for i in range( len(PolyVect) ):
        if ( Debug == True ):
            print "{0} ".format(i+1),
            sys.stdout.flush()
        y[i] = evalPoly(PolyVect[i], x, assig)
    if ( Debug == True ):
        print 

def normPolyVect(PolyVect, oldY, newY):
    ''' A 'PolyVect' is equal to 'oldY' vector. Here, the constant term
        of 'PolyVect' is put in 'oldY', generating a new 'PolyVect' and
        a 'newY'. Everything in GF(2) '''
    for i in range( len(PolyVect) ):
        Cte = PolyVect[i].constant_coefficient()
        PolyVect[i] += Cte
        newY[i] = oldY[i] + Cte

def genMatrixfromPoly(Poly, o, v, x, Matx):
    ''' From polynomial 'Poly' generates a matrix 'o x o' and
        returns the matrix in 'Matx' '''
    m = len(Poly)
    for i in range(m):  # Fill full matrix with coefficients in Poly
        numVarsPoly = len( Poly[i].variables() )
        for j in range(numVarsPoly):
            position = x.index(Poly[i].variable(j)) - v
            Matx[i,position] = 1
    return Matx

def invertPiUOV(y, o, v, x, PiUOV):
    ''' Using 'PiUOV' polynomial vector, look for a vector 'A'
        that when applied to the polynomial vector outputs 'y' '''
    counter = 1
    Matx = matrix(GF(2), o, o)
    A = vector(GF(2), v+o)
    Vvals = vector(GF(2), v)
    
    while True:
        auxPi = copy.copy(PiUOV)
        genVinegarVals(Vvals)
        onlyOilPolyVect(Vvals, auxPi, x)
        yUOV = vector(GF(2), o)     # Evaluations for UOV polynomials
        normPolyVect(auxPi, y, yUOV)
        
        Matx = genMatrixfromPoly(auxPi, o, v, x, Matx)

        try:
            solVector = Matx\yUOV
        except:
            Matx = matrix(GF(2), o, o)
            counter += 1
            continue

        print "Iterations made to find solution: ", counter
        for i in range(v):
            A[i] = Vvals[i]
        for i in range(o):
            A[ i + v ] = solVector[i]
        return A  

def genRndMatrix(matx):
    ''' Randomly generates the elements of an m x n matrix
        making sure it has full rank '''
    while True:
        for r in range( matx.nrows() ):
            for c in range( matx.ncols() ):
                matx[r,c] = ZZ.random_element(2) # <2
        if matx.rank() == matx.nrows():
            break

def genRndVector(vec):
    ''' Randomly generates the elements of an n-vector '''
    for c in range( len(vec) ):
        vec[c] = ZZ.random_element(2)   # <2

def S(Ms, x, vs):
    ''' Computes an affine transformation. Takes an nxn matrix Ms,
        an n-vector of x values and an n-constant-vector vs '''
    return ( Ms * x ) + vs

def Sinv(Ms, S, vs):
    ''' Computes an inverse affine transformation. Takes an nxn invertible
        matrix Ms, an n-vector S with computed x' values and an n-constant-
        vector vs '''
    return Ms.inverse() * ( S + vs )

def writePK(Pi, fileName, n):
    ''' Creates a file "fileName" with the contents of "Pi". Also creates
        "filename"+extPI with the polynomial integer representation. "n"
        is the number of variables in polynomials.
        If "fileName" already exists, it will be deleted!!! '''
    fo    = open(fileName, "w")
    fname = fileName + extPI
              
    for i in range( len(Pi) ):      # Write polynomials "as is"
        fo.write( str(Pi[i])+"\n" )
    PiInt = polySys2Int(Pi, n, 'x')
    writeInt(PiInt, n, fname)
    fo.close()

def writeSK(Poly, Mat, vec, fileName):
    ''' Creates a file "fileName.pol" with the polynomials of private key
        and "filename.mat" with the matrix "Mat" and vector "vec".
        If "fileName.pol" or "filename.mat" already exists,
        they will be deleted!!! '''
    fpol = fileName + extPI
    fmat = fileName + extMV
    fm = open(fmat, "w")    # Open file for matrix and vector

    n = Mat.nrows()
    
    PolyInt = polySys2Int(Poly, n, 'a') # Polynomials to integer representation
    writeInt(PolyInt, n, fpol)          # Write to file

    fm.write( str(n) + "\n" ) # Only number of rows (n x n matrix)
    for i in range( Mat.nrows() ):      # Write matrix
        aux = Ms[i]
        aux = vect2Bin( aux ).replace('(','').replace(')','')
        aux = str(int( aux, 2 ))
        fm.write( aux + " " )
    fm.write( "\n" )
    aux = vs                            # Write vector
    aux = vect2Bin( aux ).replace('(','').replace(')','')
    aux = str(int( aux, 2 ))
    fm.write( aux + " " )
    fm.write( "\n" )
    fm.close()
    

def selNumPoly(Polys):
    ''' Select a number greater than 2 and less or equal than
        the size of "Polys" '''
    numPolys = len(Polys)   # Total number of polynomials
    found    = False
    while ( not found ):
        prospect = ZZ.random_element(numPolys+1)
        if ( prospect < 2 ): continue
        found = True
    return prospect

def sumPolys(Polys, y, index):
    ''' Returns the sum of "Polys[i]" with "i" in "index"
        including also "y[i]" '''
    newPoly = 0     # To accumulate sum of symbolic variables
    equalTo = 0     # To accumulate sum of results
    for i in index:
        newPoly += Polys[i]
        equalTo += y[i]
    return newPoly, equalTo

def findLT(Poly):
    ''' Returns a set of the leader terms in the set of polynomials 'Poly' '''
    lt = []
    for i in range( len(Poly) ):
        lt.append( Poly[i].monomials()[0] )
    return set( lt )

def selIdxPoly(Polys, toSel):
    ''' From the set of polynomials "Poly", selects "toSel" indexes
        of them, returning a list with the number of these
        polynomials. This function checks that the generated polynomial
        as a linear combination of the 'Polys' selected by the found
        indexes DOES NOT has its leading term as one of the leading terms of
        any polinomial in 'Polys'. After MAX_RETRIES of looking
        to meet this conditions 'toSel' is discarded and a new number
        of polynomials is generated to break this probable loop! '''
    MAX_RETRIES   = 50
    sel         = toSel     # Originally 'toSel' polynomials will be selected
    selectedIdx = []        # Initially list empty
    numPolys = len(Polys)   # Total number of polynomials
    tries = 0               # Tries made to find polys to combine
    while ( True ):
        tries += 1
        if ( tries == MAX_RETRIES ):    # Retry another number of polynomials
                                        # to select from
            sel = selNumPoly(Polys)
            tries = 1
            print "Another number of polynomials to combine from, generated"
        for i in range( sel ):
            found = False
            while ( not found ):
                prospect = ZZ.random_element(numPolys)
                if ( prospect in selectedIdx ): continue
                selectedIdx.append(prospect)
                found = True
        ltMons = findLT(Polys)
        newPoly = 0
        for i in selectedIdx:
            newPoly += Polys[i]
        if ( newPoly.monomials()[0] in ltMons ):
            selectedIdx = []
            continue
        else:
            break
    print "Retries to find combined polynomial: {0}\n".format(tries)
    return selectedIdx

def varsInMon(monomial, varName):
    ''' Decompose a monomial in a field, into a list of integers:
        If monomial is a constant, returns: [ CTE + constant ]
        if a single variable, returns:      [ No.Var. ]
        If a variable to the 2, returns:    [ No.Var., No.Var  ]
        If two variables, returns:          [ No.Var1, No.Var2 ]
        IT IS SUPPOSED that the monomials have as variable "varName"
        and in the following "x" is shown in comments!!! '''
    variables = monomial.variables()
    if ( len(variables) == 0 ):     # Just a constant
        return [ CTE + int(monomial.coefficients()[0]) ]
    if ( len(variables) == 1 ):     # Just one variable: x0 or x0^2
        if ( 2 in monomial.exponents()[0] ):    # Case x0^2
            aux = int( str(variables[0]).replace(varName,'') )
            return [ aux, aux ]
        return [ int(str(variables[0]).replace(varName,'')) ] # Case x0
    if ( len(variables) == 2 ):     # Two variables multiplying themselves
        return [ int(str(variables[0]).replace(varName,'')),
                 int(str(variables[1]).replace(varName,'')) ] 

def poly2QF(Poly,n,varName):
    ''' Converts a single polynomial in a ring, to a matrix with quadratic
        form (n x n), a vector with linear terms and a constant.
        The matrix is upper triangular! '''
    Ge = [[0 for x in range(n)] for x in range(n)] # Init. quadratic terms matrix
    ve = [ 0 for x in range(n) ]    # Init. linear terms vector
    cons = 0                        # Constant term initial value
    
    monomials = Poly.monomials()
    for i in range( len(monomials) ):
        aux = varsInMon( monomials[i],varName )
        if ( len(aux) == 2 ):       # Quadratic terms
            Ge[aux[0]][aux[1]] = 1
            continue
        if ( len(aux) == 1 ):
            if ( aux[0] < CTE ):    # Single Variable
                ve[aux[0]] = 1
            else:                   # Constant term
                cons = aux[0] - CTE
    return Ge, ve, cons

def vect2Bin(vect):
    ''' Converts a list "vect" (as comma separated binary values)
        into a binary string '''
    aux = str(vect)
    return aux.replace('[','').replace(']','').replace(',','').replace(' ','')

def poly2Int(Poly,n,varName):
    ''' Converts a polynomial "Poly" in "n" variables to an integer
        representation: "n" numbers to form a matrix of quadratic form,
                        one number representing a vector of linear terms
                        and the constant term of the polynomial '''
    returnVect   = []   # Return vector initially empty
    Ge, ve, cons = poly2QF(Poly, n, varName)
    for i in range( n ):
        returnVect.append( int(vect2Bin(Ge[i]), 2) )    # App. quadratic terms
    returnVect.append( int(vect2Bin(ve), 2) )           # App. linear terms
    returnVect.append( cons )                           # App. constant term
    return returnVect

def polySys2Int(PolySyst, n, varName):
    ''' Converts a polynomial system "PolySyst" in a ring, to an
        integer representation. From each polynomial the quadratic, linear
        and constant terms, are converted to a binary representation and
        then converted to integers '''
    intRep = []
    for i in range( len(PolySyst) ):
        intRep.append( poly2Int(PolySyst[i], n, varName) )
    return intRep

def writeInt(listInt, n, fileName):
    ''' Creates a file "fileName" with the contents of "listInt".
        The first two fields written, are the total number of variables
        "n" and the total number of polynomials "len(listInt)".
        If "fileName" already exists, it will be deleted!!! '''
    fo = open(fileName, "wb")
    fo.write( str(n) )               # Total number of variables
    fo.write( "\n" )
    fo.write( str(len(listInt)) )    # Total number of polynomials
    fo.write( "\n" )
    for i in range( len(listInt) ):
        for j in range( len(listInt[i]) ):
            fo.write( str(listInt[i][j]) + ' ' );
        fo.write( "\n" )
    fo.close()

def readInt(filename):
    ''' Reads a file "filename" that contains rows of polynomials
        in Integer Rrepresentation. Returns an integer list with the
        data in file '''
    fi = open(filename, "rb")
    fileInt = []
    aux     = []
    
    for line in fi:         # Read file
        line = line.split()
        aux.append(line)
        
    n = int(aux[0][0])      # Get number of variables
    o = int(aux[1][0])      # and number of polynomials
    for i in range( 2, o+2 ):
        fileInt.append([ int(aux[i][j]) for j in range( n+2 )]) 
    fi.close()
    return n, o, fileInt

def int2Row(intNum, size):
    ''' Converts an integer "intNum" to its binary representation
        and returns a list of "size" bits '''
    aux  = bin( intNum )[2:]    # Converts "intNum" to a binary string
                                # cutting the leading "0b"
    laux = len(aux)
    aux  = '0'*(size-laux) + aux
    return [ int(aux[i]) for i in range( size ) ]

def intLst2Matrix(intLst,n):
    ''' Converts a list of (n+2) integers in:
        1. A matrix of (n x n)
        2. A vector of size (n)
        3. A constant bit
        All of them digits in GF(2) '''
    Ge = matrix(GF(2), n, n)    # Matrix for quadratic forms
    ve = vector(GF(2), n)       # Vector for linear terms

    L  = len(intLst)

    for i in range( L-2 ):              # Generate quadratic form matrix
        aux = int2Row(intLst[i], n)
        for j in range( n ):
            Ge[i, j] = aux[j]
    aux = int2Row(intLst[L-2], n)       # Generate linear terms
    for i in range( n ):
        ve[i] = aux[i]
    const = intLst[L-1]
    return Ge, ve, const

def MxX(M, x):
    ''' Multiplies a (n x n) Matrix (M) times 'x' (size n) '''
    n = len(x)
    v = []
    for i in range( n ):
        result = 0
        for j in range( n ):
            result += M[i][j]*x[j]
        v.append(result)
    return v

def XxV(x, V):
    ''' Multiplies a size "n" vector times a size "n" vector '''
    n = len(x)
    v = 0
    for i in range( n ):
        v += x[i]*V[i]
    return v

def int2Poly(intLst, n, x):
    ''' Converts a single polynomial represented as integers to a
        polynomial in ring "k" '''
    Ge, ve, const = intLst2Matrix(intLst, n)
    Poly  = XxV( x, MxX(Ge, x) )        # Quadratic terms here
    Poly += XxV( x, ve )                # Plus linear terms
    Poly += const                       # Plus constant term
    return Poly

def int2PolySys(IntPoly, n, x):
    ''' Converts an integer represented polynomial system to a
        system of polynomial equations in the defined ring '''
    PolySys = []
    for i in range( len(IntPoly) ):
        PolySys.append( int2Poly(IntPoly[i],n, x) )
    return PolySys

def readMat(filename):
    ''' Reads a file "filename" that contains 'n' (for n x n matrix
        and for size of vector), matrix Ms and vector
        vs. as integers. Returns n, Ms and vs '''
    fi = open(filename, "rb")
    aux   = []
    
    for line in fi:         # Read file
        aux.append(line)
        
    n = int(aux[0])                     # Number of rows=cols in matrix 'Ms'

    Ms    = matrix(GF(2), n, n)
    vs    = vector(GF(2), n)

    tmp = aux[1].split()                # Read matrix Ms
    for i in range( n ):
        row = int2Row( int(tmp[i]), n )
        for j in range( n ):
            Ms[i,j] = row[j]
    
    row = int2Row( int(aux[2]), n )     # Read vector
    for i in range( n ):
        vs[i] = row[i]
    
    fi.close()
    return n, Ms, vs

