C Simple code to write drv_vegm.dat
C from a 2D land cover file and
C land cover-1D lookup matrix
C Meant to be compiled using f2py and
C used in python to facilitate
C iterative scenario permutations.

      subroutine createclmvegm(nx,ny,nlc,dx,dy,arroutfnam,arrin,
     $ lcin_flat, arrout, lat, lon)
      integer, intent(in) :: nx, ny, nlc
      double precision, intent(in) :: dx,dy
      integer, dimension(nx,ny), intent(in) :: arrin
      integer, dimension(1,nlc), intent(in) :: lcin_flat
      double precision, dimension(nx,ny,1), intent(out) :: arrout
      integer :: i,j,k
      character*(*), arroutfnam
      real    :: lat, lon, sand, clay
      integer :: color
      real, dimension(18) :: line

Cf2py intent(in) arrin, arroutfnam
Cf2py intent(in) lcin_flat
Cf2py intent(in) nx,ny,nlc,dx,dy,dz,lat,lon
Cf2py intent(out) arrout

      sand=0.16
      clay=0.26
      color=2

C The output file
      open(13,file=arroutfnam,status='unknown',access='stream',
     $form='unformatted')

C Write the header
      write(13,*) "x  y  lat    lon    sand clay color  fractional cover
     $ age of grid by vegetation class (Must/Should Add to 1.0)"
      write(13,*) "         (Deg)  (Deg)  (%/100) index  1    2    3   4
     $    5    6    7    8    9   10  11  12  13  14  15  16  17  18"

C Begin for-loop
      do j = 1, ny
           do i = 1, nx
                do k = 1, 18
                     line(k)=0.0
                end do
                line(lcin_flat(1, arrin(i,j)))=1.0
                write(13,FMT=10) i,j,lat,lon,sand,clay,color,line
 10   format (I3, 1X, I3, 1X, F6.3, 1X, F7.3, 1X, F3.2, 1X, F3.2, 1X,
     $         I2, 1X, 18F5.2)
           end do
      end do
      end subroutine createclmvegm
