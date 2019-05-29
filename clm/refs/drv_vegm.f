C     drv_vegm.f
C     Simple code to write drv_vegm.dat from landco.txt
C     Strategy: Read inputs from GRASS
C     Write line at a time to drv_vegm.dat
      character(100) :: landcofnam, outfnam
      integer :: i,j,k
      integer :: nx,ny,nz
      integer :: err
      real    :: lat, lon, sand, clay
      integer :: color
      double precision :: dx,dy,dz
      double precision, allocatable :: landco(:,:)
      real    :: line(18)
C     END SPECIFICATIONS
      read(*,*) outfnam, landcofnam, dx, dy, nx, ny

      open(13,file=outfnam,status='unknown')
      if (err.ne.0) stop 'error opening output file'

      open(14,file=landcofnam,iostat=err, status='old')
      if (err.ne.0) stop 'error opening landcover file'


C      dx=10.0d0
C      dy=10.0d0
C      dz=1.0d0

C      nx=128
C      ny=96
C      nz=77

      lat=39.313
      lon=-76.688
      sand=0.16
      clay=0.26
      color=2
      allocate(landco(nx,ny))

      do j = 1, ny
           read(14,*) (landco(i, (ny+1)-j) , i=1,nx)
      end do
      write(13,*) "x  y  lat    lon    sand clay color  fractional cover
     &age of grid by vegetation class (Must/Should Add to 1.0)"
      write(13,*) "         (Deg)  (Deg)  (%/100) index  1    2    3   4
     &    5    6    7    8    9   10  11  12  13  14  15  16  17  18"
      do j = 1, ny
           do i = 1, nx
                do k = 1, 18
                     line(k)=0.0
                end do
                if(landco(i,j).ge.3) then
C     Building, Road/Rail, Other Paved mapped to Bare Soil
C     Bare Soil mapped to Bare Soil
C     Category 4 Water mapped to Water Bodies
                              line(18)=1.0
                              if(landco(i,j).eq.4) then
                                   line(17)=1.0
                              end if
                else if (landco(i,j).eq.2) then
                        line(10)=1.0
                else if (landco(i,j).eq.1) then
                        line(4)=1.0
                end if
                write(13,FMT=10) i,j,lat,lon,sand,clay,color,line
 10   format (I3, 1X, I3, 1X, F6.3, 1X, F7.3, 1X, F3.2, 1X, F3.2, 1X,
     &         I2, 1X, 18F5.2)
           end do
      end do
      end
