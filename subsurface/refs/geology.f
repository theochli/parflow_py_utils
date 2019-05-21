C     Geology.f
C     Simple code to write geology input files to PFB files
C     Strategy: Read inputs from GRASS
C     PFB files will be 3D and match the dimensions of the computational
C     grid
      integer i,j,k
      integer nx,ny,nz
      integer err
      double precision dx,dy,dz
      double precision, allocatable :: permeability(:,:,:)
      double precision, allocatable :: mask(:,:,:)
      double precision, allocatable :: mannings(:,:,:)
      double precision, allocatable :: indicator(:,:,:)
      double precision, allocatable :: landco(:,:)
      double precision, allocatable :: dem(:,:)
      integer, allocatable :: demint(:,:)
      character(100) permfnam, manningsfnam 
      character(100) indicatorfnam, demfnam
      real thickness
      real dem_min
C     END SPECIFICATIONS
      permfnam='permeability.pfb'
      manningsfnam='mannings.pfb'
      indicatorfnam='indicator.pfb'      
      demfnam='dem.txt'
      
      open(13,file='out.txt',status='unknown')

      open(14,file='landco.txt',iostat=err, status='old')
      if (err.ne.0) stop 'error opening landcover file'

      open(16,file=demfnam, iostat=err, status='old')

      dx=10.0d0
      dy=10.0d0
      dz=1.0d0

      nx=132
      ny=96
      nz=77
      
      allocate(mask(nx,ny,nz))
      allocate(indicator(nx,ny,nz))
      allocate(permeability(nx,ny,nz))
      allocate(mannings(nx,ny,1))
      allocate(landco(nx,ny))
      allocate(dem(nx,ny))
      allocate(demint(nx,ny))
      do j = 1, ny
           read(14,*) (landco(i, (ny+1)-j) , i=1,nx)
           read(16,*) (dem(i, (ny+1)-j) , i=1,nx)
      end do 
      dem_min=minval(dem)
      thickness=30.0
      do i = 1, nx
           do j = 1, ny
             dem(i,j)=(dem(i,j))*0.3048d0+(thickness-(dem_min*0.3048d0))
             demint(i,j)= dnint(dem(i,j))
           end do
      end do

C      call pfb_read(mask,'deadrun.out.mask.pfb',nx,ny,nz)
C      do i = 1, nx
C           do j=1, ny
C               do k= 1,nz
C                   if(mask(i,j,(nz+1)-k).ne.0) then
C                       if(demint(i,j).ne.((nz+1)-k)) then
C                       print*, i, j, ((nz+1)-k)
C                       print*, 'doh!'
C                       end if
C                       cycle 
C                   end if 
C               end do
C           end do
C      end do
      do i = 1, nx
           do j = 1, ny
C                mannings(i,j,k)=-9999.0d0
                if(landco(i,j).ge.5) then 
C     Mannings from Chow for smooth asphalt
C     pg 111
                              mannings(i,j,1)=0.013d0/3600.0d0
C     Mannings from Chow for 
C     minor streams pg 112 
                else
                              mannings(i,j,1)=0.03d0/3600.0d0
                end if
           end do
      end do
      do i = 1, nx
           do j= 1, ny
                do k= 1, nz
C     Surface Layer
                     if(k.eq.demint(i,j)) then
                         print*, i,j,k
C          Impervious
                         if (landco(i,j).ge.5) then
                              permeability(i,j,k)=0.002124d0
                              indicator(i,j,k)=5.0d0
C          Pervious          
                         else 
                              permeability(i,j,k)=0.0227d0
                              indicator(i,j,k)=1.0d0
                         end if
                     end if
C     Saprolite 
                     if((k.le.((demint(i,j)-1))).and.(k.ge.
     .                                   ((demint(i,j)-14)))) then
                              permeability(i,j,k)=0.00556d0
                              indicator(i,j,k)=2.0d0
                     end if
C     High Zone      
                     if((k.lt.(demint(i,j)-14)).and.(k.ge.(demint(i,j)
     .                                                          -17)))
     .               then
                              permeability(i,j,k)=0.227d0
                              indicator(i,j,k)=3.0d0
                     end if
C     Bedrock 
                     if((k.lt.(demint(i,j)-17))) then
                              permeability(i,j,k)=0.00001d0
                              indicator(i,j,k)=4.0d0
                     end if
                     if(k.gt.demint(i,j)) then
                              permeability(i,j,k)=-999
                              indicator(i,j,k)=-999
                     end if
C     Checks
C                     if (indicator(i,j,k).ne.5) then
C                             if (indicator(i,j,k).ne.6) then 
C                     print*, indicator(i,j,k)
C                             end if
C                     end if
                end do
           end do
      end do
      print*, permfnam, nx,ny,nz,dx,dy,dz
      call pf_write(permeability,permfnam,nx,ny,nz,dx,dy,dz)
      print*,indicatorfnam, nx,ny,nz,dx,dy,dz
      call pf_write(indicator,indicatorfnam,nx,ny,nz,dx,dy,dz)
C     Write mannings for top layer only, change nz to 1
      nz=1
      print*, manningsfnam, nx,ny,nz,dx,dy,dz
      call pf_write(mannings,manningsfnam,nx,ny,nz,dx,dy,dz)
      end
