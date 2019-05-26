import { StudentService } from '../../core/services/student.service';
import { Component, OnInit } from '@angular/core';

import { StudentDetails } from '../../core/models/student-details.model';

@Component({
  selector: 'app-details',
  templateUrl: './details.component.html',
  styleUrls: ['./details.component.scss']
})
export class DetailsComponent implements OnInit {

  constructor(public studentService: StudentService) { }

  public student: StudentDetails ;
  

  ngOnInit() {
      this.studentService.getStudent().subscribe(student => this.student = student);
  }

}
