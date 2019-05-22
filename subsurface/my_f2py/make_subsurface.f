C     make_subsurface.f
C     Simple code to write subsurface input files (permeability and
C     indicator) to PFB files
C     PFB files will be 3D and match dimensions of the computational
C     grid.
C
C     Strategy: Read inputs from Python-produced landcover file
C        FOR USE AS A PYTHON MODULE

      subroutine zsubsurf(dx,dy,dz,nx,ny,nz,landco,perm,man,ind)

      integer i,j,k
      integer nx,ny,nz
C      integer err
      double precision dx,dy,dz
      double precision, allocatable :: landco(:,:)
      double precision, allocatable :: perm(:,:,:)
      double precision, allocatable :: man(:,:,:)
      double precision, allocatable :: ind(:,:,:)


      character(100) permfnam, manningsfnam
      character(100) indicatorfnam

C     END SPECIFICATIONS
      permfnam='permeability.pfb'
      manningsfnam='mannings.pfb'
      indicatorfnam='indicator.pfb'

C      open(14,file='landco.txt',iostat=err, status='old')
C      if (err.ne.0) stop 'error opening landcover file'

      dx=10.0d0
      dy=10.0d0
      dz=1.0d0

      nx=30
      ny=50
      nz=10

      allocate(ind(nx,ny,nz))
      allocate(perm(nx,ny,nz))
      allocate(man(nx,ny,1))
      allocate(landco(nx,ny))

C     Read in land cover file  -- is this do needed here?
      do j = 1, ny
           read(14,*) (landco(i, (ny+1)-j) , i=1,nx)
      end do


C     Write Mannings
      do i = 1, nx
           do j = 1, ny
                if(landco(i,j).ge.5) then
                     man(i,j,1)=0.013d0/3600.0d0
                else
                     man(i,j,1)=0.03d0/3600.0d0
                end if
           end do
      end do

C     Subsurface Layers
C     the "surface" layer is nz
      do i = 1, nx
           do j= 1, ny
                do k= nz, 1, -1
C     Surface Layers
                     if(k.eq.nz) then
                         print*, i,j,k
C          Urban
                         if (landco(i,j).eq.1) then
                              perm(i,j,k)=0.002124d0
                              ind(i,j,k)=5.0d0
C          Forested
                         else
                              perm(i,j,k)=0.0227d0
                              ind(i,j,k)=1.0d0
                         end if
                     end if
C     Common Saprolite Layers
                     if((k.lt.10.and.(k.ge.8))) then
                              perm(i,j,k)=0.00556d0
                              ind(i,j,k)=2.0d0
                     end if
C     Common TZ Layers
                     if((k.lt.8.and.(k.ge.5))) then
                              perm(i,j,k)=0.227d0
                              ind(i,j,k)=3.0d0
                     end if
C     Common Bedrock Layer
                     if(k.eq.1) then
                              perm(i,j,k)=0.00001d0
                              ind(i,j,k)=4.0d0
                     end if

                end do
           end do
      end do
      print*, permfnam, nx,ny,nz,dx,dy,dz
      call pf_write(perm,permfnam,nx,ny,nz,dx,dy,dz)
      print*,indicatorfnam, nx,ny,nz,dx,dy,dz
      call pf_write(ind,indicatorfnam,nx,ny,nz,dx,dy,dz)
C     Write mannings for top layer only, change nz to 1
      nz=1
      print*, manningsfnam, nx,ny,nz,dx,dy,dz
      call pf_write(man,manningsfnam,nx,ny,nz,dx,dy,dz)
      end
