

FVector getMouseGroundPlaneIntersection(float eyeX, float eyeY, float eyeZ,
			float centerX, float centerY,
			float centerZ, float upX, float upY, float upZ) {
  //generate the required vectors
  FVector eye = new FVector(eyeX, eyeY, eyeZ);
  FVector center = new FVector(centerX, centerY, centerZ);
  FVector look = (center.subtract(eye)).normalize();
  FVector up = new FVector(upX, upY, upZ).normalize();
  FVector left = up.crossProduct(look.normalize());

  //calculate the distance between the mouseplane and the eye
  float distanceEyeMousePlane = (height / 2) / tan(PI / 6);

  //calculate the vector, that points from the eye
  //to the clicked point, the mouse is on
  FVector mousePoint = look.multiply(distanceEyeMousePlane);
  mousePoint=mousePoint.add(left.multiply((float)((mouseX-width/2)*-1)));
  mousePoint=mousePoint.add(up.multiply((float)(mouseY-height/2)) );

  FVector intersection = new FVector(3);
  if (mousePoint.getZ() != 0) { //avoid zero division
    //calculate the value, the vector that points to the mouse
    //must be multiplied with to reach the XY-plane
    float multiplier = -eye.getZ() / mousePoint.getZ();
    //do not calculate intersections behind the camera
    if (multiplier > 0) { 
	//add the multiplied mouse point vector
	intersection = eye.add(mousePoint.multiply(multiplier));  
    }
  }
  return intersection;
 
} 






//FVector.pde by David Huebner  (2005|06|05)
//last changes                  (2005|06|21)
//modify and use in any way

//Vector class with N float elements. Built for Processing 0.90.
//To get it working in Java you need the core.jar library from processing or delete/change the methods using matrices.

//This vector class ist not limited to a 3D vector, although some of the methods only work with 3 dimensions.

//Most methods have a second variant.
//The normal one like multiply() returns a new vector with the calculations applied to.
//The one with "Me" in its name like multiplyMe() applies the calculations to this vector.

//Please report any bugs and additions to David@millbridge.de

//import processing.core.*; // for class PMatrix

public class FVector {

	public static final float TOL = 0.00001f;
	
	private int N;		//the number of elements of this vector
	public float e[]; 	//the array which contains all the elements of this vector
	
	//constructor for creating a null-vector with n elements 
	public FVector(int n) {
		N = n;
		e = new float[N];
		for( int i=0; i<N; i++ )
			e[i] = 0;
	}
	
	//constructor for creating a vector from a given array of float values	
	public FVector(float[] ee) {
		N = ee.length;
		e = new float[N]; 
		for( int i=0; i<N; i++ )
			e[i] = ee[i]; 
	}
	
	//constructor for creating a vector with the same elements of another vector v1. Similar to cloning a vector.	
	public FVector(FVector v2) {
		N = v2.e.length;
		e = new float[N]; 
		for( int i=0; i<N; i++ )
			e[i] = v2.e[i]; 
	}
	
	//constructor for creating a 3D vector with specified values _x, _y and _z	
	public FVector(float _x, float _y, float _z) {
		N = 3;
		e = new float[3]; 
		e[0] = _x;
		e[1] = _y;
		e[2] = _z;
	}
	
	//returns the magnitude of this vector
	public float magnitude() {
		float sum = 0.0f;
		for ( int i=0; i<N; i++ )
			sum = sum + e[i] * e[i];
		return (float)Math.sqrt( sum<TOL?TOL:sum );	 
	}
	
	//returns the squared magnitude of this vector
	public float magnitudeSqr() {
		float sum = 0.0f;
		for ( int i=0; i<N; i++ )
			sum = sum + e[i] * e[i];
		return (float)sum<TOL?TOL:sum;	 
	}
	
	//returns a new vector as a result of adding another vector v2 to this vector
	public FVector add(FVector v2) {
		FVector product = new FVector(N);
		if( N == v2.N )
			for ( int i=0; i<N; i++ )
				product.e[i] = e[i] + v2.e[i];
		else
			System.err.println( "FVector.add(): FVectors differ in dimension!" );
		return product;
	}
	
	//adds another vector v2 to this vector
	public void addMe(FVector v2) {
		if( N == v2.N )
			for ( int i=0; i<N; i++ )
				e[i] += v2.e[i];
		else
			System.err.println( "FVector.add(): FVectors differ in dimension!" );
	}
	
	//returns a new vector as a result of subtracting another vector v2 from this vector
	public FVector subtract(FVector v2) {
		FVector product = new FVector(N);
		if( N == v2.N )
			for ( int i=0; i<N; i++ )
				product.e[i] = e[i] - v2.e[i];
		else
			System.err.println( "FVector.subtract(): FVectors differ in dimension!" );
		return product;
	}
	
	//subtracts another vector v2 from this vector
	public void subtractMe(FVector v2) {
		if( N == v2.N )
			for ( int i=0; i<N; i++ )
				e[i] -= v2.e[i];
		else
			System.err.println( "FVector.subtract(): FVectors differ in dimension!" );
	}
	
	//returns a new vector as a result of multiplying this vector with a given float value v
	public FVector multiply(float v) {
		FVector product = new FVector(N);
		for ( int i=0; i<N; i++ )
			product.e[i] = e[i] * v;
		return product;
	}
	
	//multiplies this vector with a given float value v
	public void multiplyMe(float v) {
		for ( int i=0; i<N; i++ )
			e[i] *= v;
	}
	
	//returns a new vector as a result of dividing this vector by a given float value v
	public FVector divide(float v) {
		v = (v < TOL)?TOL:v;
		FVector product = new FVector(N);
		for ( int i=0; i<N; i++ )
			product.e[i] = e[i] / v;
		return product;
	}
	
	//divides this vector by a given float value v
	public void divideMe(float v) {
		v = (v < TOL)?TOL:v;
		for ( int i=0; i<N; i++ )
			e[i] /=	v;
	}
	
	//returns a new vector with the same direction of this vector, but with a length of 1
	public FVector normalize() {
		return divide(magnitude());
	}
	
	//makes this vector to have a length of 1
	public void normalizeMe() {
		FVector norm = new FVector(divide(magnitude()));
		for ( int i=0; i<N; i++ )
			e[i] = norm.e[i];
	}
	
	//returns the crossproduct of this vector and a given vector v2. see math book for description of the crosproduct
	public FVector crossProduct(FVector v2)
	{
		FVector crossProduct = new FVector(3);
		if (N == 3	&&	v2.N == 3) //cross product only defined in R3
		{
			crossProduct.e[0] = e[1] * v2.e[2] - e[2] * v2.e[1];
			crossProduct.e[1] = e[2] * v2.e[0] - e[0] * v2.e[2];
			crossProduct.e[2] = e[0] * v2.e[1] - e[1] * v2.e[0];
		}
		else
			System.err.println("FVector.crossProduct(): FVectors are not both in R3!");
		return crossProduct;
	}
	
	//returns the dotproduct of this vector and a given vector v2. see math book for description of the dotproduct
	public float dotProduct (FVector v2)
	{
		float sum = 0;
		if (N == v2.N)
			for ( int i=0; i<N; i++ )
				sum += e[i] * v2.e[i];
		else
			System.err.println("FVector.dotProduct(): FVectors differ in dimension!");
		return sum;
	}
	
	//returns true, if this vector equals a null-vector
	public boolean isZero() {
		boolean zero = true;
		for ( int i=0; i<N; i++ )
			if (e[i] != 0.0f) {
				zero = false;
				break;
			}
		return zero;
	}
	
	//returns true, if this vector equals a given vector v2
	public boolean equals(FVector v2) {
		boolean same = true;
		if (N == v2.N) {
			for ( int i=0; i<N; i++ )
				if (e[i] != v2.e[i]) {
					same = false;
					break;
				}
		}
		else {
			System.err.println("FVector.equals(): FVectors differ in dimension!");
			same = false;
		}
		return same;
	}
	
	//returns a new vector as a result of rotating this vector around the x-axis by a given float value val (in radians)
	public FVector rotateX(float val) {
		FVector result = new FVector(this);
		if (N > 2) {
			double cosval = Math.cos(val);
			double sinval = Math.sin(val);
			double tmp1 = e[1]*cosval - e[2]*sinval;
			double tmp2 = e[1]*sinval + e[2]*cosval;
		
			result.e[1] = (float)tmp1;
			result.e[2] = (float)tmp2;
		}
		else
			System.err.println("FVector.rotateX(): FVector is not in R3 or higher");
	
		return result;
	}
	
	//rotates this vector around the x-axis by a given float value val (in radians)
	public void rotateMeX(float val) {
		if (N > 2) {
			double cosval = Math.cos(val);
			double sinval = Math.sin(val);
			double tmp1 = e[1]*cosval - e[2]*sinval;
			double tmp2 = e[1]*sinval + e[2]*cosval;
		
			e[1] = (float)tmp1;
			e[2] = (float)tmp2;
		}
		else
			System.err.println("FVector.rotateMeX(): FVector is not in R3 or higher");
	}
	
	//returns a new vector as a result of rotating this vector around the y-axis by a given float value val (in radians)
	public FVector rotateY(float val) {
		FVector result = new FVector(this);
		if (N > 2) {
			double cosval = Math.cos(val);
			double sinval = Math.sin(val);
			double tmp1	 = e[0]*cosval - e[2]*sinval;
			double tmp2	 = e[0]*sinval + e[2]*cosval;
		
			result.e[0] = (float)tmp1;
			result.e[2] = (float)tmp2;
		}
		else
			System.err.println("FVector.rotateY(): FVector is not in R3 or higher");
	
		return result;
	}
	
	//rotates this vector around the y-axis by a given float value val (in radians)
	public void rotateMeY(float val) {
		if (N > 2) {
			double cosval = Math.cos(val);
			double sinval = Math.sin(val);
			double tmp1	 = e[0]*cosval - e[2]*sinval;
			double tmp2	 = e[0]*sinval + e[2]*cosval;
		
			e[0] = (float)tmp1;
			e[2] = (float)tmp2;
		}
		else
			System.err.println("FVector.rotateMeY(): FVector is not in R3 or higher");
	}
	
	//returns a new vector as a result of rotating this vector around the z-axis by a given float value val (in radians)
	//can be used for 2D Vectors too
	public FVector rotateZ(float val) {
		FVector result = new FVector(this);
		if (N > 1) {
			double cosval = Math.cos(val);
			double sinval = Math.sin(val);
			double tmp1	 = e[0]*cosval - e[1]*sinval;
			double tmp2	 = e[0]*sinval + e[1]*cosval;
		
			result.e[0] = (float)tmp1;
			result.e[1] = (float)tmp2;
		}
		else
			System.err.println("FVector.rotateMeZ(): FVector is not in R2 or higher");
		
		return result;
	}
	
	//rotates this vector around the z-axis by a given float value val (in radians)
	//can be used for 2D Vectors too
	public void rotateMeZ(float val) {
		if (N > 1) {
			double cosval = Math.cos(val);
			double sinval = Math.sin(val);
			double tmp1	 = e[0]*cosval - e[1]*sinval;
			double tmp2	 = e[0]*sinval + e[1]*cosval;
			
			e[0] = (float)tmp1;
			e[1] = (float)tmp2;
		}
		else
			System.err.println("FVector.rotateMeZ(): FVector is not in R2 or higher");
	}
	
	//rotates this vector around a given axis v2 by a given float value val (in radiens)
	public FVector rotateAxis(float val, FVector v2) {
		FVector result = new FVector(this);
		
		if (N == 3 && v2.N == 3) {
			PMatrix3D rotateMatrix = new PMatrix3D();
			rotateMatrix.rotate(val, v2.e[0], v2.e[1], v2.e[2]);
			
			float in[]	= {e[0], e[1], e[2], 0};
			float out[]	= {0, 0, 0, 0};
			rotateMatrix.mult(in,out);
			
			result.e[0] = out[0];
			result.e[1] = out[1];
			result.e[2] = out[2];
		}
		else
			System.err.println("FVector.rotateAxis(): FVectors are not both in R3");
		
		return result;
	}
	
	//returns a new vector as a result of rotating this vector around a given axis v2 by a given float value val (in radiens)
	public void rotateAxisMe(float val, FVector v2) {
		if (N == 3 && v2.N == 3) {
			PMatrix3D rotateMatrix = new PMatrix3D();
			rotateMatrix.rotate(val, v2.e[0], v2.e[1], v2.e[2]);
			
			float in[]	= {e[0], e[1], e[2], 0};
			float out[]	= {0, 0, 0, 0};
			rotateMatrix.mult(in,out);
			
			e[0] = out[0];
			e[1] = out[1];
			e[2] = out[2];
		}
		else
			System.err.println("FVector.rotateAxisMe(): FVectors are not both in R3");
	}
	
	//returns the value of the 1st element of this vector
	public float getX() {
		return e[0];
	}
	
	//returns the value of the 2nd element of this vector
	public float getY() {
		return e[1];
	}
	
	//returns the value of the 3rd element of this vector
	public float getZ() {
		return e[2];
	}
	
	//sets the 1st element to a given value newX
	public void setX(float newX) {
		e[0] = newX;
	}
	
	//sets the 2nd element to a given value newY
	public void setY(float newY) {
		e[1] = newY;
	}
	
	//sets the 3rd element to a given value newZ
	public void setZ(float newZ) {
		e[2] = newZ;
	}
	
	//changes the elements of this vector to the values of another vector
	public void set(FVector v2)
	{
		for ( int i=0; i<Math.min(N,v2.N); i++ )
			e[i] = v2.e[i];
	}
	
	//changes the first three elements of this vector to the given values x, y, z
	public void set(float x, float y, float z)
	{
		if (N > 2) {
			e[0] = x;
			e[1] = y;
			e[2] = z;
		}		
		else
			System.err.println("FVector.set(): FVector's dimension is too small");
	}
	
	//changes the elements of this vector to the values of a given float array
	public void set(float x[])
	{
		for ( int i=0; i<Math.min(N,x.length); i++ )
			e[i] = x[i];
	}

	//returns a new vector with the same elements the this vector
	public FVector cloneMe() {
		return new FVector(this);
	}

} //end of class FVector


