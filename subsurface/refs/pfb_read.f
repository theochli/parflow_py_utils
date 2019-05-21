C Subroutine pfb_read
      subroutine pfb_read(value,fname,nx,ny,nz) 
      implicit none
      real*8 value(nx,ny,nz)
      real*8 dx, dy, dz, x1, y1, z1
      integer*4 i,j,k, nni, nnj, nnk, ix, iy, iz
      integer*4 ns,rx,ry,rz,nx,ny,nz, nnx, nny, nnz,is
      character(len=*) fname
  
      open(100,file=trim(adjustl(fname)),form='unformatted',
     .     access='stream',convert='BIG_ENDIAN',status='old') 
C Read in header info

C Start: reading of domain spatial information
      read(100) x1 !X
      read(100) y1 !Y 
      read(100) z1 !Z

      read(100) nx !NX
      read(100) ny !NY
      read(100) nz !NZ

      read(100) dx !DX
      read(100) dy !DY
      read(100) dz !DZ

      read(100) ns !num_subgrids
C End: reading of domain spatial information

C Start: loop over number of sub grids
      do is = 0, (ns-1)

C Start: reading of sub-grid spatial information
      read(100) ix
      read(100) iy
      read(100) iz

      read(100) nnx
      read(100) nny
      read(100) nnz
      read(100) rx
      read(100) ry
      read(100) rz

C End: reading of sub-grid spatial information

C Start: read in saturation data from each individual subgrid
      do  k=iz +1 , iz + nnz
       do  j=iy +1 , iy + nny
        do  i=ix +1 , ix + nnx
         read(100) value(i,j,k)
        end do
       end do
      end do
C End: read in saturation data from each individual subgrid

C End: read in saturation data from each individual subgrid

      end do
C End: loop over number of sub grids



      close(100)
      end subroutine
