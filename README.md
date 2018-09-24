# sml_triangle
Introduction to Functional Programming – Rendering a Triangle

By Mehar Samra, San Marcos High School, October 2018

Code to render a colored traingle using scanline rendering implented in a functional programming language SML. I developed this
project over the summer. The functional programming language I used is called SML (Standard Meta Language) and the implementation came with Isabelle, a theorem prover, which supports SML and comes with a free development environment.

In a traditional programming language, we would use a standard construct such as a for-loop, that step by step goes over each scanline. But in SML we will use a recursive function to accomplish the same thing. The results will be stored in a segment list.

The function intersect_triangle does the line intersection for each of the three lines in the triangle at the scanline y. The results are put in a list, which is clipped and sorted. The clipping function will make sure the intersection happens on the valid edge of the
triangle, and the sorting will make the intersections be ordered correctly. 

Intersecting a line is a straightforward use of algebra to
find the gradient and y-intercept of a linear graph for each triangle edge, and then finding the x value given the known scanline y.

The remaining part of the code is the recursive call to the triangle intersection function described earlier. The render_scanline function is below and calls the triangle intersection function described earlier. And yes, this is another recursive function! This recursion enables the endering to be broken down scanline by scanline.

Finally the segment list and does the mixing of the colors which is saved to a file. The file format I used is PPM, which is a simple format that can represent colors.

