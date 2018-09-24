(* Mehar Samra, San Marcos High School *)
(* This program renders a colored triangle and outputs it to a PPM file *)

(* my data structures for color, point, line, and triangle*)
datatype color = Color of {
        r : real,
        g : real,
        b : real
};
datatype point = Point of {
        x : real,
        y : real
};
datatype colorpoint = ColorPoint of {
      p : point,
      c : color
};
datatype line = Line of {
        p1 : point,
        p2 : point,
        c1 : color,
        c2 : color
};
datatype triangle = Triangle of {
        line1 : line,
        line2 : line,
        line3 : line
};

(* mix two colors *)
fun mix(Color{r=r1,g=g1,b=b1}, Color{r=r2,g=g2,b=b2}, factor) = 
  Color({
          r = r1*factor  + r2*(1.0-factor),
          g = g1*factor  + g2*(1.0-factor),
          b = b1*factor  + b2*(1.0-factor)
          });

(* gradient of a two points *)
fun gradient(Point{x=x1,y=y1}, Point{x=x2,y=y2}) = 
    if Real.==(x1,x2) then 0.0 else (y2-y1)/(x2-x1);

(* the y-intersect based on a point and gradient *)
fun yintercept(Point{x=x1,y=y1}, m) = 
    y1-m*x1;

(* ratio of between y1..y2, this is used to create mixed colors on each line based on the start and end points *)
fun ratio(Point{x=_,y=y1}, Point{x=_,y=y2}, y) = 
     if  Real.==(y1,y2) then 0.0 else (y-y1)/(y2-y1);

(* range test to check if x is in the valid range between two points *)
fun inxrange(Point{x=x1,y=_}, Point{x=x2,y=_}, x) =
  if x>=x1 andalso x<=x2 then true else false;

(* intersects a line at y, the result will be the point where it intersects and the mixed color  *)
fun intersect_line(y, Line{p1=p1,p2=p2,c1=c1,c2=c2}) = 
              let 
                      val m = gradient(p1, p2);
                      val b = yintercept(p1, m);
                      val x = if Real.==(m,0.0) then 0.0 else (y-b)/m; 
                      val r = abs(ratio(p1, p2, y));
              in
                      if(inxrange(p1, p2, x)) then
                          ColorPoint({ p=Point({x=x,y=y}), c=mix(c1, c2, r) })
                      else  if(inxrange(p2, p1, x)) then
                          ColorPoint({ p=Point({x=x,y=y}), c=mix(c2, c1, r) })
                      else (* invalid *)
                          ColorPoint({ p=Point({x= ~1.0,y= ~1.0}), c=mix(c2, c1, r) })
              end;

(* clip out invalid points, this removes the invalid cases where the scanline doesnt intercept *)
fun clip([]) = []
| clip (ColorPoint{p=Point{x=x,y=y},c=c}::rest) = 
              if(x<0.0) then
                clip(rest)
              else
                ColorPoint{p=Point{x=x,y=y},c=c}::clip(rest);
      
(* sort the points in increasing x values *)
fun sort []  = []
| sort (c1 :: []) = c1 :: []
| sort (c1 :: c2  :: rest) =
              let
                    val ColorPoint{p=Point{x=x1, ... }, ... } = c1;
                    val ColorPoint{p=Point{x=x2, ... }, ... } = c2;
              in
                  if(x2<x1) then
                      c2 :: c1 :: sort(rest)
                  else
                      c1 :: c2 :: sort(rest)
              end;

(* intersect a triangle at line y by recursivley intersecting it's line and return the list of interpolated color points, which are sorted and clipped *)
fun intersect_triangle(y, Triangle{line1=l1,line2=l2,line3=l3}) =
              let
                    val colorpoints = intersect_line(y, l1) :: 
                                      intersect_line(y, l2) :: 
                                      intersect_line(y, l3) :: [];
              in
                    sort(clip(colorpoints))
              end;



val black =  Color({r=0.0,g=0.0,b=0.0});

(* output scanline *)
fun output_scanline(file, w, x, x1, x2, color1, color2) =   
              let 
                val factor = if Real.==(x2,x1) then 0.0 else (x2-x)/(x2-x1);
                val Color{r=r, g=g, b=b} = mix(color1, color2, factor);
                val _ = if(x>=w) then 
                      BinIO.output(file,Byte.stringToBytes("\n"))
                    else if x >= x1 andalso x<=x2 then 
                      BinIO.output(file, Byte.stringToBytes(Int.toString(round(r*100.0)) ^ " " ^ Int.toString(round(g*100.0)) ^ " " ^ Int.toString(round(b*100.0)) ^ " "))  
                    else 
                      BinIO.output(file, Byte.stringToBytes("0 0 0 "))
              in
                    if(x>=w) then  0 else output_scanline(file, w, x+1.0, x1, x2, color1, color2)
              end; 

fun render_scanline(file, w, y, t) =
              if(y<0.0) then
                []
              else
                let
                  val segment_list = intersect_triangle(y, t);
                  val ColorPoint{p=Point{x=x1, ...}, c=color1} = if List.length(segment_list) < 1 then ColorPoint{p=Point{x=0.0,y=y},c=black} else List.nth(segment_list, 0);
                  val ColorPoint{p=Point{x=x2, ...}, c=color2} = if List.length(segment_list) < 2 then ColorPoint{p=Point{x=w-1.0,y=y},c=black} else List.nth(segment_list,1);
                  val _ = output_scanline(file, w, 0.0, x1, x2, color1, color2);
               in
                  render_scanline(file, w, y-1.0, t) 
               end;


(* create the colored triangle *)
val red   =  Color({r=1.0,g=0.0,b=0.0});
val green =  Color({r=0.0,g=1.0,b=0.0});
val blue  =  Color({r=0.0,g=0.0,b=1.0});
val pt1   =  Point({x=10.0,y=5.0});
val pt2   =  Point({x=250.0,y=5.0});
val pt3   =  Point({x=128.0,y=250.0}); 
val mytriangle = Triangle({
                            line1 = Line({p1=pt1, p2=pt2, c1=red, c2=green}),
                            line2 = Line({p1=pt2, p2=pt3, c1=green, c2=blue}),
                            line3 = Line({p1=pt3, p2=pt1, c1=blue, c2=red})
                           });

(* render and output the colored triangle *)
fun output_image(filename, width, height) =
            let val file = BinIO.openOut(filename); 
             val _ = BinIO.output(file, Byte.stringToBytes("P3\n") );
             val _ = BinIO.output(file, Byte.stringToBytes(" # Mehar's Picture Output\n") );
             val _ = BinIO.output(file, Byte.stringToBytes(Int.toString(width) ^ " " ^ Int.toString(height)  ^ "\n" ));
             val _ = BinIO.output(file, Byte.stringToBytes("100\n") );
             val _ = render_scanline(file, real(width), real(height), mytriangle);
            in BinIO.closeOut(file)
            end;    

output_image("C:/Users/mehar/Desktop/triangle.ppm", 256, 256); 