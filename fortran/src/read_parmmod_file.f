      subroutine read_parmmod_file(inbound,ntr,ns,idtusec)
         implicit none
!       read a configuration file

      character (len=255) :: inbound, inbound_locked
      integer*4  ntr,ns,idtusec
      integer :: err_message, ready

!      print *, 'read_parmmod_file, inbound is:',trim(inbound),'--'
!      in case inbound is of a different, but shorter length in main
!      inbound=inbound
      inbound_locked=trim(inbound)//"_locked"

10     open(status='new',unit=25,file=inbound_locked,iostat=ready)

        if (ready.eq.0) then
         open(unit=26,file=trim(inbound),status='old',
     +    iostat=err_message)

!       check whether file opens data file
         if (err_message.eq.0) then

          read (26,*) ntr,ns,idtusec
!       print *, 'read_parmmod_file, results',ntr,ns,idtusec
!          print *, 'read_parmmod_file.f, result',result
          close (unit=26)

         else
!         print *, 'read_parmmod_file.f, err_message=',err_message
!         print *, 'read_parmmod_file.f, counter=',counter
!         rest a little before trying again
!         call sleep(1)
          go to 10
         end if
       else
         print *, 'read_parmmod_file.f,locked, try again,read =',ready
         go to 10
       end if
!       remove lock file
11      close (status='delete',unit=25,iostat=err_message)
        if (err_message.ne.0) then
         go to 11
         print *, 'read_parmmod_file.f, err_messg=',err_message
        end if

      end subroutine read_parmmod_file
