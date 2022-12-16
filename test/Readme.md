# Explanation of our testing

To test for single cycle, Run `./SingleCycle.sh` in terminal with the correct files loaded into the instruction and data memory
## F1 lights testing

To test our program, we ran it using the do it file that is in the rtl, base folder. Our expected outcome is for each light to come on incrementally, when the trigger is pressed, then a random delay when they're all lit before the lights then turning off.



https://user-images.githubusercontent.com/116260803/207304050-5d9542f9-8b06-49fd-bb07-cabc23c90fe9.mp4

(NOTE: we used the website veed.io to compress our video so that we could upload it to github)

As expected, the F1 lights program works and we can clearly see the random delay implemented as there are two different delays in the two cycles we ran.


## Single-cycle CPU Reference Program testing

In testing we used the following line in the cpp file to sample the wave:

``` cpp
   if (simcyc>1000000 && simcyc% 9 == 0)
```
This allows us to view it in periods rather than a continuous wave thus decreaseing the wavelength and making the graph more readable

To test the reference program, we had to specify, in accordance to the data map provided in the reference program repo, where we start writing to, we did this in the following way:
``` verilog
  $readmemh("DataMemory.mem", RAM, 32'h10000);
```
This specifies that the first address we are writing to is 0x00010000

### Sine
For the sine pdf, we load the sine folder into the memory and the expected reult is a 'U' shape, better demonstrated by the following picture from google: 

![pdf](https://user-images.githubusercontent.com/116260803/208064721-96a666b8-6b0b-4d1e-9562-6cd7e3d1feff.png)

Our reult on the Vbuddy was this:

https://user-images.githubusercontent.com/116260803/208066300-21f66f0b-25b2-4496-b9a5-edae37865ba4.MOV

While it is moving relatively quickly, we can clearly see the 'U' shape as expected.


### Noisy Sine

The noisy sine was fairly similar to the sine except with a little more noise so we expected it to look similar to the following:

![VCAE3](https://user-images.githubusercontent.com/116260803/208067676-1a17cc6b-804e-4ff6-b1bf-98bdaa832c99.png)

This was our result on the vbuddy:

https://user-images.githubusercontent.com/116260803/208068304-7f4a3588-3e87-4d9a-9db5-7c561093632f.mov

There are multiple cycles present on the vbuddy dissplay but once again we can clearly see our results match as expected


### Gaussian

The guassian function had a PDF that looked very similar to a normal distribution and so we expected the following result on the vbuddy:

![Probability-Density-Function-of-the-Standard-Gaussian-Distribution-with-Mean-of-Zero-and](https://user-images.githubusercontent.com/116260803/208069193-202852b2-bb64-45b9-9963-a117117bdfb0.png)

Our display on the vbuddy was as follows:


https://user-images.githubusercontent.com/116260803/208069568-d8e3182b-54d5-42fa-a0db-0077772770f2.MOV

Once more, the video cuts at the start of the second cycle but we can clearly see that it matches the photo.


### Triangle

The triangle wave has a pdf of a square wave, as shown by the following image off of google:

<img width="203" alt="Screenshot 2022-12-16 at 09 51 29" src="https://user-images.githubusercontent.com/116260803/208072036-2bd08311-3ec9-40f0-ac5e-c5ca500eaf3c.png">

This is our output on the Vbuddy:


https://user-images.githubusercontent.com/116260803/208072385-2f514729-b3ab-464a-b1b4-fa561683a94f.MOV

This is the same as expected.

All these tests confirm that our single-cycle cpu works with both the reference program as well as the F1 lights program as expected.

The exact same output was seen when we ran with pipelining
