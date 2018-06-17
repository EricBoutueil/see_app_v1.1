require 'test_helper'

class ImporterTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @user = users(:admin)
    # there are 5 rows in that file
    @file = file_fixture("movements.csv")
  end

  test "dispatch a csv file into multiples jobs" do
    # stub Importer.rows_per_job so we can verify the split at each 2 rows
    Importer.stub :rows_per_job, 2 do
      assert_enqueued_jobs 3, only: ImportJob do
        Importer.enqueue_jobs(@user, @file)
      end
    end
  end

  test "enqueue ImportJob with the expected arguments" do
    assert_enqueued_with(job: ImportJob, queue: 'import', args: [@user.id, csv_file_to_named_rows(@file)]) do
      Importer.enqueue_jobs(@user, @file)
    end
  end

  test "enqueue finnish import job" do
    assert_enqueued_with(job: FinnishImportJob, queue: 'import', args: [@user.id]) do
      Importer.enqueue_jobs(@user, @file)
    end
  end
end
