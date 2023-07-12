{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2023, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Implements a non-modal dialogue box that is displayed during long processes.
}


unit SWAGView.UI.WaitDlg;

interface

uses
  System.Classes,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Forms,
  FMX.StdCtrls,
  FMX.Types;

type
  ///  <summary>Form class that implements a non-modal dialogue box that is
  ///  displayed during long processes.</summary>
  TWaitDlg = class(TForm)
    MessageLbl: TLabel;
    procedure FormShow(Sender: TObject);
  private
    var
      fWaitMessage: string;
  public
    property WaitMessage: string read fWaitMessage write fWaitMessage;
  end;

implementation

{$R *.fmx}

procedure TWaitDlg.FormShow(Sender: TObject);
begin
  MessageLbl.Text := fWaitMessage;
  Application.ProcessMessages;
end;

end.

